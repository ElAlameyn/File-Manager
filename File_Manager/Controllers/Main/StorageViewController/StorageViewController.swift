//
//  StorageViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit
import Combine

class StorageViewController: UIViewController {
  
  typealias Section = LayoutManager.StorageSections
  typealias DataSource = UICollectionViewDiffableDataSource<Section, StorageItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StorageItem>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<StorageItem>

  private let usageSpaceViewModel = UsageSpaceViewModel()
  private let filesViewModel = FilesModel()
  
  private var authorizeAgain = PassthroughSubject<Void, Never>()
  private var reloadFiles = PassthroughSubject<String, Never>()
  
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  private var cancellables: Set<AnyCancellable> = []
  private var inverse: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Storage"
    view.backgroundColor = Colors.baseBackground
    
    configureCollectionView()
    fetch()
    bindViewModels()
    applySnapshot()
  }
  
  #warning("Fix api calls")
  
  private func fetch() {
    // Fetch and store usage space
    DropboxAPI.shared.fetchUsageSpace()?
      .sink(receiveCompletion: {
        switch $0 {
        case .finished: print("SUCCESS USAGE SPACE FETCH")
        case .failure(let error):
          print("Failed fetch due to \(error)")
          self.usageSpaceViewModel.handleFail(on: self) {
            DropboxAPI.shared.fetchUsageSpace()?
              .sink(receiveCompletion: {_ in}, receiveValue: {
                self.usageSpaceViewModel.subject.send($0)
              }).store(in: &self.cancellables)
          }
        }
      }, receiveValue: {
        self.usageSpaceViewModel.subject.send($0)
      }
      ).store(in: &cancellables)
  }
  
  private func bindViewModels() {
    // Update usage space
    usageSpaceViewModel.subject
      .sink(receiveCompletion: {_ in}, receiveValue: { response in
        self.updateUsageSpace(usageSpaceResponse: response)
      }).store(in: &cancellables)
    
    
    authorizeAgain.sink { _ in
      let authVC = AuthViewController()
      authVC.modalPresentationStyle = .fullScreen
      self.present(authVC, animated: true)
      authVC.dismissed = {
        authVC.dismiss(animated: true)
//        self.reloadFiles.send(self.path.current)
      }
    }
    .store(in: &cancellables)
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: StorageItem) -> UICollectionViewCell? in
      
      switch item {
      case .usageSpace(let info):
        let cell: UsageSpaceCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(usageSpace: info)
        return cell
      case .recentlyUploaded(let item):
        let cell: FileItemCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: item.name)
        return cell
      }
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
      view.downArrowButton.isHidden = false
      
      switch Section(rawValue: indexPath.section) {
      case .usageSpace: break
      case .recentlyUpload: view.titleLabel.text = "Recently uploaded"
      default: break
      }
      return view
    }
    return dataSource
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections(Section.allCases)
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func updateUsageSpace(usageSpaceResponse: UsageSpaceResponse?) {
    var snapshot = SectionSnapshot()
    snapshot.append([StorageItem.usageSpace(usageSpaceResponse)])
    self.dataSource.apply(snapshot, to: .usageSpace, animatingDifferences: true)
  }
  
  private func updateListFiles(files: [ListFoldersResponse.File]?) {
    var snapshot = SectionSnapshot()
    if let storages = files?.compactMap({ StorageItem.recentlyUploaded($0)}) {
      snapshot.append(storages)
      self.dataSource.apply(snapshot, to: .recentlyUpload, animatingDifferences: true)
    }
  }
  
  private func configureCollectionView() {
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: LayoutManager.createStorageViewControllerLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(UsageSpaceCell.self, forCellWithReuseIdentifier: "\(UsageSpaceCell.self)")
    collectionView.register(FileItemCell.self, forCellWithReuseIdentifier: "\(FileItemCell.self)")

    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)")
    
    view.addSubview(collectionView)
  }
  
}

