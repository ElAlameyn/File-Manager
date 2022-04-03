//
//  StatisticViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 05.02.2022.
//

import UIKit
import Combine

class FilesViewController: UIViewController {
  
  typealias Section = LayoutManager.FilesSections
  typealias DataSource = UICollectionViewDiffableDataSource<Section, FileItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FileItem>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<FileItem>
  
  private let filesViewModel = FilesViewModel()
  private var collectionView: UICollectionView! = nil
  private lazy var dataSource = configureDataSource()
  
  private var cancellables: Set<AnyCancellable> = []
  private var subscriber: AnyCancellable?
  
  private let searchController = UISearchController()
  private var path = Path()
  
  private var isRootFolder: Bool {
    path.current == ""
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = .white
    title = "Files"
    
    navigationItem.searchController = searchController
    searchController.searchResultsUpdater = self
    
    configureCollectionView()
    reloadViewWithFiles(at: path.current)
    bindViewModels()
    initSnaphot()
  }
  
  // MARK: - Fetch & Update Data
  
  private func bindViewModels() {
    filesViewModel.subject
      .sink(receiveCompletion: {_ in}) { files in
        self.update(files: files?.entries, updateLastModified: true)
      }
      .store(in: &cancellables)
  }
  
  private func reloadViewWithFiles(at path: String) {
    DropboxAPI.shared.fetchAllFiles(path: path, recursive: false)?
      .sink(receiveCompletion: {
        switch $0 {
        case .finished: break
        case .failure(let error):
          print("Failed fetch due to \(error)")
          self.filesViewModel.handleFail(on: self) {
            self.reloadViewWithFiles(at: self.path.current)
          }
        }
        
      }, receiveValue: {
        self.filesViewModel.subject.send($0)
      }).store(in: &cancellables)
  }
  
  private func initSnaphot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.lastModified, .main])
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func update(files: [ListFoldersResponse.File]?, updateLastModified: Bool? = false) {
    var mainSnapshot = SectionSnapshot()
    var modifiedSnapshot = SectionSnapshot()
    if let storages = files?.compactMap({ FileItem(file: $0) }) {
      if !isRootFolder {
        var updated = [FileItem()]
        updated += storages
        mainSnapshot.append(updated)
      } else {
        mainSnapshot.append(storages)
      }
      self.dataSource.apply(mainSnapshot, to: .main, animatingDifferences: true)
    }
    
    guard updateLastModified! else { return }
    
    @Limited<FileItem>(limit: 4) var modified
    self.filesViewModel.filteredByDateModified().forEach {
      modified.append(FileItem(file: $0))
    }
    
    modifiedSnapshot.append(modified)
    dataSource.apply(modifiedSnapshot, to: .lastModified, animatingDifferences: true)
  }
}

// MARK: - Collection View

extension FilesViewController {
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: LayoutManager.createFilesViewLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(FileItemCell.self, forCellWithReuseIdentifier: "\(FileItemCell.self)")
    collectionView.register(LastModifiedCell.self, forCellWithReuseIdentifier: "\(LastModifiedCell.self)")
    collectionView.register(ReturnFileCell.self, forCellWithReuseIdentifier: "\(ReturnFileCell.self)")
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)")
    
    collectionView.register(
      FoldersHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(FoldersHeaderView.self)")
    
    collectionView.delegate = self
    view.addSubview(collectionView)
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) { [self]
      (collectionView: UICollectionView, indexPath: IndexPath, item: FileItem) -> UICollectionViewCell? in
      
      guard let section = Section(rawValue: indexPath.section) else { return nil }
      switch section {
      case .lastModified:
        let cell: LastModifiedCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: item.file?.name, tag: item.file?.tag)
        return cell
      case .main:
        if !isRootFolder {
          if indexPath.row == 0 && indexPath.section == 1 {
            let cell: ReturnFileCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell
          }
        }
        let cell: FileItemCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.handleMenu = self
        cell.indexPath = indexPath
        cell.configure(title: item.file?.name, tag: item.file?.tag)
        return cell
      }
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      switch Section(rawValue: indexPath.section) {
      case .lastModified:
        let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        view.titleLabel.text = Texts.fileSectionLastModified
        return view
      case .main:
        let view: FoldersHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        view.titleLabel.text = Texts.fileSectionAllFiles
        view.delegate = self
        return view
      default: return nil
      }
    }
    return dataSource
  }
  
}

// MARK: - UICollectionViewDelegate

extension FilesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch LayoutManager.FilesSections.allCases[indexPath.section] {
    case .lastModified: break
    case .main:
      // Handle back arrow tap
      if indexPath.row == 0 && indexPath.section == 1  && !isRootFolder {
        reloadViewWithFiles(at: self.path.getPrevious ?? "")
        
        // Change show path label
        let view: FoldersHeaderView = collectionView.getSupplementaryView(at: IndexPath(row: 0, section: 1))
        view.currentPathLabel.text = self.path.wasPrevious
        return
      }
      
      // Handle tap on folder
      let selected = isRootFolder ? filesViewModel.allFiles[indexPath.row] : filesViewModel.allFiles[indexPath.row - 1]
      if selected.tag == "folder" {
        guard let path = selected.pathDisplay else { return }
        self.path.current = path
        let view: FoldersHeaderView = collectionView.getSupplementaryView(at: IndexPath(row: 0, section: 1))
        view.currentPathLabel.text = self.path.current
        reloadViewWithFiles(at: self.path.current)
      }
    }
  }
}


// MARK: - UISearchResultsUpdating

extension FilesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    subscriber = NotificationCenter.default.publisher(
      for: UISearchTextField.textDidChangeNotification,
      object: searchController.searchBar.searchTextField
    )
    .map { $0.object as? UISearchTextField }
    .map { $0?.text }
    .sink { [weak self] text in
      guard let text = text, let self = self else { return }
      if !text.isEmpty {
        DropboxAPI.shared.fetchSearch(q: text)?
          .sink(receiveCompletion: {_ in}, receiveValue: { data in
            let files = data?.matches.compactMap { $0.metadata.metadata }
            self.update(files: files)
          })
          .store(in: &self.cancellables)
      }
    }
  }
}

// MARK: - HandlingFileMenuOperations

extension FilesViewController: HandlingFileMenuOperations {
  func didShareTapped(for indexPath: IndexPath) {
  }
  
  func didShowPreviewTapped(for indexPath: IndexPath) {
  }
  
  func didRenameTapped(for indexPath: IndexPath) {
  }
  
  func didDeleteTapped(for indexPath: IndexPath) {
    DropboxAPI.shared.fetchDeleteFile(
      at: filesViewModel.allFiles[indexPath.row].pathDisplay ?? ""
    )?
      .sink(receiveCompletion: {
        switch $0 {
        case .finished: print("[API SUCCESSFUL] - Delete file")
        case .failure(let error): print("[API FAIL] - Delete file:", error)
        }
      }, receiveValue: {_ in
        self.reloadViewWithFiles(at: self.path.current)
      })
      .store(in: &cancellables)
  }
}

// MARK: - HandlingFolderView

extension FilesViewController: HandlingFolderView {
  func addFolder() {
    let manager = BulletinManager()
    manager.presentOn(viewController: self)
    manager.textFieldItem.textPublisher()
      .sink { text in
        DropboxAPI.shared.fetchCreateFolder(with: text, at: self.path.current)?
          .sink(receiveCompletion: {
            switch $0 {
            case .finished: print("[API SUCCESSFUL] - Create folder:")
            case .failure(let error): print("[API FAIL] - Create folder:", error)
            }
          }, receiveValue: {_ in
            self.reloadViewWithFiles(at: self.path.current)
          })
          .store(in: &self.cancellables)
        
        manager.dismiss()
      }
      .store(in: &self.cancellables)
  }
  
  func addPaper() {
  }
}

