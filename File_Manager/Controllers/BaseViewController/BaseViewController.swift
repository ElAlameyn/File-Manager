//
//  BaseViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit

class BaseViewController: UIViewController {
  
  enum Section {
    case title, category, recentFiles
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, BaseItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, BaseItem>
  
  private let sections: [Section] = [.title, .category, .recentFiles]
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    configureUI()
    applySnapshot()
  }
  
  // MARK: - Data Source
  
  private func configureDataSource() -> DataSource {
    return DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: BaseItem) -> UICollectionViewCell? in
      
      var category: Category?
      var recents: RecentFile?
      
      switch item {
      case .title:
        break
      case .category(let itemCategory):
        category = itemCategory
      case .recents(let itemRecents):
        recents = itemRecents
      }
      
      switch self.sections[indexPath.section] {
      case .title:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "\(TitleBaseViewCell.self)" ,
          for: indexPath) as? TitleBaseViewCell
        else { fatalError("Can't find a cell") }
        return cell
      case .category:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "\(CategoryBaseViewCell.self)" ,
          for: indexPath) as? CategoryBaseViewCell
        else { fatalError("Can't find a cell") }
        
        cell.titleLabel.text = category?.title
        cell.imageView.image = category?.image
        return cell
      case .recentFiles:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "\(RecentBaseViewCell.self)" ,
          for: indexPath) as? RecentBaseViewCell
        else { fatalError("Can't find a cell") }
        cell.mainImageView.image = recents?.image
        return cell
      }
    }
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.title, .category, .recentFiles])
    snapshot.appendItems( [.title] , toSection: .title)
    snapshot.appendItems(BaseItem.allCategories, toSection: .category)
    snapshot.appendItems(BaseItem.allRecents, toSection: .recentFiles)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  // MARK: - Collection View SetUP
  
  private func configureUI() {
    addLeftBarButtonItem()
    addRightBarButtonItem()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(TitleBaseViewCell.self, forCellWithReuseIdentifier: "\(TitleBaseViewCell.self)")
    collectionView.register(CategoryBaseViewCell.self, forCellWithReuseIdentifier: "\(CategoryBaseViewCell.self)")
    collectionView.register(RecentBaseViewCell.self, forCellWithReuseIdentifier: "\(RecentBaseViewCell.self)")
    view.addSubview(collectionView)
  }
  
  // MARK: - Layout
  
  private func createLayout() -> UICollectionViewLayout {
    let sectionProvider = {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      switch self.sections[sectionIndex] {
        // MARK: - Title Layout
      case .title:
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)),
          subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
        
        // MARK: - Category Layout
      case .category:
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .absolute(130),
            heightDimension: .absolute(150)),
          subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 15
        
        return section
        
        // MARK: - Recent Files Layout
      case .recentFiles:
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .estimated(155),
            heightDimension: .estimated(220)))
        

        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(220)),
          subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: nil, bottom: NSCollectionLayoutSpacing.fixed(20))
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(10)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = NSDirectionalEdgeInsets(top: 60, leading: 30, bottom: 5, trailing: 30)

        return section
      }
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
  
  // MARK: - Navigation Buttons

  private func addLeftBarButtonItem() {
    let button = UIButton(type: .custom)
    button.setImage(Images.baseLeftItem, for: .normal)
    button.sizeToFit()

    button.addTarget(self, action: #selector(leftBarButtonItemTapped), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
  }

  private func addRightBarButtonItem() {
    let button = UIButton(type: .custom)
    button.setImage(Images.baseRightItem, for: .normal)
    button.sizeToFit()

    button.addTarget(self, action: #selector(rightBarButtonItemTapped), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
  }
  
  @objc func leftBarButtonItemTapped() {
    print("Left button tapped")
  }
  
  @objc func rightBarButtonItemTapped() {
    print("Left button tapped")
  }
}
