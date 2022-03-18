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
  private let filesViewModel = FilesViewModel()
  
  private var images: [ImageIdContainer] = [] {
    didSet {
      updateImages()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModels()
    applySnapshot()
    filesViewModel.fetch(f: DropboxAPI.shared.fetchAllFiles())
  }
  
  private func bindViewModels() {
    filesViewModel.update = { [weak self] in
      guard let self = self else { return }
      self.filesViewModel.images.forEach { [weak self] in
        self?.images.append(ImageIdContainer(
          imageId: $0.id,
          imageName: $0.name
        ))
      }
    }
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems( [] , toSection: .main)
    self.dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func updateImages() {
    var snapshot = SectionSnapshot()
    snapshot.append(images)
    dataSource.apply(snapshot, to: .main, animatingDifferences: true)
  }

  private func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(ImageBaseViewCell.self, forCellWithReuseIdentifier: "\(ImageBaseViewCell.self)")
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)")
    
    view.addSubview(collectionView)
    collectionView.delegate = self
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource =  DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: ImageIdContainer) -> UICollectionViewCell? in
      let cell: ImageBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
      if !cell.isFethed {
        cell.fetch(id: item.imageId ?? "")
      }
      return cell
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
      view.titleLabel.text = "All Images"
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

extension ImagesCollectionController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let detailVC = DetailImageController(imageName: images[indexPath.row].imageName ?? "")
    detailVC.modalPresentationStyle = .fullScreen
    guard let item = collectionView.cellForItem(at: indexPath) as? ImageBaseViewCell else { return }
    if item.isFethed {
      present(detailVC, animated: true) {
        detailVC.change(image: item.mainImageView.image)
      }
    }
  }
}
