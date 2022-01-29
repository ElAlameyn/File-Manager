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
  
  private let sections: [Section] = [.title, .category, .recentFiles]
  var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
  private var collectionView: UICollectionView! = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    
    configureHierarchy()
    configureDataSource()
  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
      
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TitleBaseViewCell.self)" ,
                                                          for: indexPath) as? TitleBaseViewCell else { fatalError("Can't find a cell") }
      return cell
    }
    
    // Define how many section and row need
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.title])
    snapshot.appendItems(Array(0...0))
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func configureHierarchy() {
    addLeftBarButtonItem()
    addRightBarButtonItem()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(TitleBaseViewCell.self, forCellWithReuseIdentifier: "\(TitleBaseViewCell.self)")
    view.addSubview(collectionView)
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let sectionProvider = { [weak self]
      (sectionIndex: Int,
       layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      switch self?.sections[sectionIndex] {
      case .title:
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)),
          subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
      case .category:
        return nil
      case .recentFiles:
        return nil
      case .none:
        fatalError("PIzdec nahui blyat")
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
