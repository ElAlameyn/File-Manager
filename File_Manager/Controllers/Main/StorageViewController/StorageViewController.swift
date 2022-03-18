//
//  StorageViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit
import Combine

class StorageViewController: UIViewController {
  enum Section: Int {
    case usageSpace, lastModified
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, StorageItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StorageItem>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<StorageItem>
  
  private let sections: [Section] = [.usageSpace, .lastModified]
  
  private let usageSpaceViewModel = UsageSpaceViewModel()
  private let filesViewModel = FilesViewModel()
  
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  private var cancellables: Set<AnyCancellable> = []
  private var inverse: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Storage"
    view.backgroundColor = Colors.baseBackground
    
    configureUI()
    bindViewModels()
    applySnapshot()
    usageSpaceViewModel.fetch(f: DropboxAPI.shared.fetchUsageSpace)
    filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles())
  }
  
  private func bindViewModels() {
    usageSpaceViewModel.$value
      .sink(receiveValue: {[weak self] value in
        self?.updateUsageSpace(usageSpaceResponse: value)
      })
      .store(in: &cancellables)
    
    filesViewModel.update = { [weak self] in
      guard let self = self else { return }
      self.updateListFiles(files: self.filesViewModel.filteredByDateModified())
    }
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: StorageItem) -> UICollectionViewCell? in
      
      switch item {
      case .usageSpace(let info):
        let cell: UsageSpaceCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(usageSpace: info)
        return cell
      case .lastModified(let item):
        let cell: FileItemCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: item.name)
        return cell
      }
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
      view.descrButton.isHidden = false
      view.delegate = self
      
      switch Section(rawValue: indexPath.section) {
      case .usageSpace: break
      case .lastModified: view.titleLabel.text = "Last Modified"
      case .none: break
      }
      return view
    }
    return dataSource
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.usageSpace, .lastModified])
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func updateUsageSpace(usageSpaceResponse: UsageSpaceResponse?) {
    var snapshot = SectionSnapshot()
    snapshot.append([StorageItem.usageSpace(usageSpaceResponse)])
    self.dataSource.apply(snapshot, to: .usageSpace, animatingDifferences: true)
  }
  
  private func updateListFiles(files: [ListFoldersResponse.File]?) {
    var snapshot = SectionSnapshot()
    if let storages = files?.compactMap({ StorageItem.lastModified($0)}) {
      snapshot.append(storages)
      self.dataSource.apply(snapshot, to: .lastModified, animatingDifferences: true)
    }
  }

  private func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
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
  
  private func createLayout() -> UICollectionViewLayout {
    let sectionProvider = {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
      -> NSCollectionLayoutSection? in
      switch self.sections[sectionIndex] {
      case .usageSpace:
        
        let item = LayoutManager.createItem(
          wD: .estimated(330),
          hD: .estimated(420))
        
        let group = LayoutManager.createHorizontalGroup(
          wD: .fractionalWidth(1.0),
          hD: .estimated(420),
          item: item)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 30, bottom: 40, trailing: 30)
        
        return section
        
      case .lastModified:
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 30, bottom: 80, trailing: 30)
        section.interGroupSpacing = 15
        
        let sectionHeader = LayoutManager.createSectionHeader(
          wD: .fractionalWidth(1.0),
          hD: .estimated(30))
        section.boundarySupplementaryItems = [sectionHeader]

        return section
      }
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
}

extension StorageViewController: SortButtonDelegate {
  
  func sortButtonTapped() {
    inverse.toggle()
//    updateListFiles(files: filesViewModel.value?.filteredByDateModified(inverse: inverse))
  }
  
}
