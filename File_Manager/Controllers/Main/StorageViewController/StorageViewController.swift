//
//  StorageViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

class StorageViewController: UIViewController {
  enum Section: Int {
    case statistics, lastModified
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, StorageItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StorageItem>
  
  private let sections: [Section] = [.statistics, .lastModified]
  
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Storage"

    view.backgroundColor = Colors.baseBackground
    configureUI()
    applySnapshot()
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: StorageItem) -> UICollectionViewCell? in
      
      // TO-DO: add Statistic and configure
      
      var statistic: Statistic?
      var lastModifiedItem: LastModifiedItem?
      
      switch item {
      case .statistics(let itemStatistic):
        statistic = itemStatistic
      case .lastModified(let itemModified):
        lastModifiedItem = itemModified
      }
      
      switch self.sections[indexPath.section] {
      case .statistics:
        let cell: StatisticCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(statistic: statistic)
        return cell
      case .lastModified:
        let cell: ModifiedItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: lastModifiedItem?.title, image: lastModifiedItem?.image)
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
      case .statistics:
        break
      case .lastModified:
        view.titleLabel.text = "Last Modified"
      case .none:
        break
      }
      return view
    }
    return dataSource
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.statistics, .lastModified])
    snapshot.appendItems( [StorageItem.statistic] , toSection: .statistics)
    snapshot.appendItems(StorageItem.allModifiedItems, toSection: .lastModified)
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(StatisticCollectionViewCell.self, forCellWithReuseIdentifier: "\(StatisticCollectionViewCell.self)")
    collectionView.register(ModifiedItemCollectionViewCell.self, forCellWithReuseIdentifier: "\(ModifiedItemCollectionViewCell.self)")

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
      case .statistics:
        
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
    StorageItem.allModifiedItems.sort()
    applySnapshot()
  }
  
  
}
