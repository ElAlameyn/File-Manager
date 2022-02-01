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

    // Do any additional setup after loading the view.
    view.backgroundColor = Colors.baseBackground
    configureUI()
    applySnapshot()
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: StorageItem) -> UICollectionViewCell? in
      
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
        return cell
      case .lastModified:
        let cell: ModifiedItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.titleLabel.text = lastModifiedItem?.title
        if let image = lastModifiedItem?.image {
//          cell.imageView.image = ImageTransformator.scaled(image: image)
          cell.imageView.image = image
        }
        return cell
      }
    }
    return dataSource
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.statistics, .lastModified])
    snapshot.appendItems( [StorageItem.statistic] , toSection: .statistics)
    snapshot.appendItems(StorageItem.allModifiedItems, toSection: .lastModified)
    self.dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(StatisticCollectionViewCell.self, forCellWithReuseIdentifier: "\(StatisticCollectionViewCell.self)")
    collectionView.register(ModifiedItemCollectionViewCell.self, forCellWithReuseIdentifier: "\(ModifiedItemCollectionViewCell.self)")

    // TO-DO add supplementary view
    
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 50, leading: 30, bottom: 5, trailing: 30)
        
        return section
        
      case .lastModified:
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 60, leading: 30, bottom: 20, trailing: 30)
        section.interGroupSpacing = 15
        
        // TO-DO add supplementary view

        return section
      }
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
}
