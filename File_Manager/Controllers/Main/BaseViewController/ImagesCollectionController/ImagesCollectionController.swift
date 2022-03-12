//
//  ImagesCollectionController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 05.03.2022.
//

import UIKit
import Combine

class ImagesCollectionController: UIViewController
{
  enum Section {
    case main
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageIdContainer>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageIdContainer>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ImageIdContainer>
  
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  private let listFoldersViewModel = FilesViewModel()
  private var cancellables: Set<AnyCancellable> = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModels()
    applySnapshot()
  }
  
  private func bindViewModels() {
    
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems( [] , toSection: .main)
    self.dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func updateImages(response: ListFoldersResponse? = nil) {
    var snapshot = SectionSnapshot()
//    let items = listFoldersViewModel.images(response).map { ImageModel(image: <#T##UIImage?#>, imageName: <#T##String#>) }
//    snapshot.append(items)
    dataSource.apply(snapshot, to: .main, animatingDifferences: true)
  }
  
  private func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(RecentBaseViewCell.self, forCellWithReuseIdentifier: "\(RecentBaseViewCell.self)")
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)")
    
    view.addSubview(collectionView)
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource =  DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: ImageIdContainer) -> UICollectionViewCell? in
      let cell: RecentBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
//      cell.configure(image: item.image)
      return cell
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
      view.titleLabel.text = "Images"
      return view
    }
    return dataSource
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let sectionProvider = {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
      -> NSCollectionLayoutSection? in
      
      let item = LayoutManager.createItem(
        wD: .estimated(155),
        hD: .estimated(220))
      
      let group = LayoutManager.createHorizontalGroup(
        wD: .fractionalWidth(1.0),
        hD: .estimated(220),
        item: item)
      
      group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: nil, bottom: NSCollectionLayoutSpacing.fixed(20))
      group.interItemSpacing = NSCollectionLayoutSpacing.flexible(10)
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 40, trailing: 20)
      
      let sectionHeader = LayoutManager.createSectionHeader(
        wD: .fractionalWidth(1.0),
        hD: .estimated(30))
      section.boundarySupplementaryItems = [sectionHeader]
      
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
}
