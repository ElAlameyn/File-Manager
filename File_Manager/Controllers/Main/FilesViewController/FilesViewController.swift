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
  
  private let sections = Section.allCases
  private let filesViewModel = FilesViewModel()
  private var collectionView: UICollectionView! = nil
  private lazy var dataSource = configureDataSource()
  
  private var cancellables: Set<AnyCancellable> = []
  private var subscriber: AnyCancellable?
  
  private let searchController = UISearchController()
  private var path = Path()

  private var isFirstLoaded = true
  private var isRootFolder: Bool {
    path.current == ""
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = .white
    title = "Files"
    
    configureCollectionView()
    bindViewModels()
    initSnaphot()
    
    filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles(recursive: false))
    navigationItem.searchController = searchController
    searchController.searchResultsUpdater = self
  }
  
  // MARK: - Update
  
  private func bindViewModels() {
    filesViewModel.update = { [weak self] in
      guard let self = self else { return }
      self.update(files: self.filesViewModel.allFiles, updateLastModified: self.isFirstLoaded)
      self.isFirstLoaded = false
    }
    
    filesViewModel.failedRequest = { [weak self] in
      guard let self = self else { return }
      self.filesViewModel.handleFail(on: self) {
        self.filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles())
      }
    }
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
        let cell:LastModifiedCell = collectionView.dequeueReusableCell(for: indexPath)
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
        view.titleLabel.text = "Last Modified"
        return view
      case .main:
        let view: FoldersHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        view.titleLabel.text = "All Files"
        return view
      default: return nil
      }
    }
    return dataSource
  }
}

extension FilesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch LayoutManager.FilesSections.allCases[indexPath.section] {
    case .lastModified:
      break
    case .main:
      if indexPath.row == 0 && indexPath.section == 1  && !isRootFolder {
        filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles(path: self.path.getPrevious ?? "", recursive: false))
        let view: FoldersHeaderView = collectionView.getSupplementaryView(at: IndexPath(row: 0, section: 1))
        view.currentPathLabel.text = self.path.previous
        return
      }
      let selected = isRootFolder ? filesViewModel.allFiles[indexPath.row] : filesViewModel.allFiles[indexPath.row - 1]
      if selected.tag == "folder" {
        guard let path = selected.pathDisplay else { return }
        self.path.current = path
        let view: FoldersHeaderView = collectionView.getSupplementaryView(at: IndexPath(row: 0, section: 1))
        view.currentPathLabel.text = self.path.current
        filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles(path: path, recursive: false))
      }
    }
  }
}

// MARK: - Search

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
      if text.isEmpty { self.filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles()) }
      DropboxAPI.shared.fetchSearch(q: text)?
        .sink(receiveCompletion: {_ in}, receiveValue: { data in
          let files = data?.matches.compactMap { $0.metadata.metadata }
          self.update(files: files)
        })
        .store(in: &self.cancellables)
    }
  }
}

extension FilesViewController {
  
  /// Struct for displaing folder path
  private struct Path {

    var current: String {
      get {
        all.last ?? ""
      }
      set {
        previous = current
        all.append(newValue)
      }
    }
    
    var previous: String?
    
    var getPrevious: String? {
      mutating get {
        all.removeLast()
        previous = all.last
        return previous
      }
      set {
        previous = newValue
      }
    }
    var all = [String]()
  }

}
