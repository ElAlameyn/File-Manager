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
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
  typealias TitleSnapshot = NSDiffableDataSourceSnapshot<Section, Int>
  
  private let sections: [Section] = [.title, .category, .recentFiles]
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    configureUI()
    applySnapshot()
  }
  
  private func configureDataSource() -> DataSource {
    return DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
      
      switch self.sections[indexPath.section] {
      case .title:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TitleBaseViewCell.self)" ,
                                                            for: indexPath) as? TitleBaseViewCell else { fatalError("Can't find a cell") }
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blue.cgColor
        return cell
      case .category:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CategoryBaseViewCell.self)" ,
                                                            for: indexPath) as? CategoryBaseViewCell else { fatalError("Can't find a cell") }
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blue.cgColor
        return cell
      case .recentFiles:
        return nil
      }
    }
  }
  
  private func applySnapshot() {
    var snapshot = TitleSnapshot()
    snapshot.appendSections([.title, .category])
    snapshot.appendItems([0], toSection: .title)
    snapshot.appendItems([1, 2, 3, 4, 5, 6, 7], toSection: .category)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func configureUI() {
    addLeftBarButtonItem()
    addRightBarButtonItem()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(TitleBaseViewCell.self, forCellWithReuseIdentifier: "\(TitleBaseViewCell.self)")
    collectionView.register(CategoryBaseViewCell.self, forCellWithReuseIdentifier: "\(CategoryBaseViewCell.self)")
    view.addSubview(collectionView)
  }
  
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
            widthDimension: .absolute(110),
            heightDimension: .absolute(130)),
          subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return section
        
        // MARK: - Recent Files Layout
      case .recentFiles:
        return nil
      }
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
  

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
