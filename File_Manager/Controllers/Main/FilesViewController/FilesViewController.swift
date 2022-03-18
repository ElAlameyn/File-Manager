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
  private let sections = Section.allCases
  private let searchController = UISearchController()
  private var subscriber: AnyCancellable?
  

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
      self.update(files: self.filesViewModel.allFiles)
    }
  }
  
  private func initSnaphot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.lastModified, .main])
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func update(files: [ListFoldersResponse.File]?) {
    var mainSnapshot = SectionSnapshot()
    var modifiedSnapshot = SectionSnapshot()
    if let storages = files?.compactMap({ FileItem(file: $0) }) {
      mainSnapshot.append(storages)
      self.dataSource.apply(mainSnapshot, to: .main, animatingDifferences: true)
    }
    
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
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)")
    
    collectionView.delegate = self
    view.addSubview(collectionView)
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: FileItem) -> UICollectionViewCell? in
      
      guard let section = Section(rawValue: indexPath.section) else { return nil }
      switch section {
      case .lastModified:
        let cell:LastModifiedCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: item.file?.name, tag: item.file?.tag)
        return cell
      case .main:
        let cell: FileItemCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: item.file?.name, tag: item.file?.tag)
        return cell
      }
      
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
      view.descrButton.isHidden = false
      switch Section(rawValue: indexPath.section) {
      case .lastModified: view.titleLabel.text = "Last Modified"
      case .main: view.titleLabel.text = "All Files"
      default: break
      }
      return view
    }
    return dataSource
  }
}

extension FilesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selected = filesViewModel.allFiles[indexPath.row]
    if selected.tag == "folder" {
      guard let path = selected.pathDisplay else { return }
      filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles(path: path, recursive: false))
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
