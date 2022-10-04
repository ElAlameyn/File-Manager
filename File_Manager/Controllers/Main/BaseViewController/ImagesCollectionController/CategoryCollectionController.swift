//
//  ImagesCollectionController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 05.03.2022.
//

import UIKit
import Combine

class CategoryCollectionController: UIViewController
{
  enum Section {
    case main
  }
  
  enum TypeOfCategory {
    case file
    case image
  }
  
  var type: TypeOfCategory! = nil
  
  convenience init(type: TypeOfCategory) {
    self.init(nibName: nil, bundle: nil)
    self.type = type
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, ItemContainer>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemContainer>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemContainer>
  
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  private let listFoldersViewModel = FilesViewModel()
  private var cancellables: Set<AnyCancellable> = []
  private let filesViewModel = FilesViewModel()
  
  private var images: [ItemContainer] = [] {
    didSet {
      updateImages()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden  = false
    
    configureUI()
    fetch()
    bindViewModels()
    applySnapshot()
  }
  
#warning("Fix handle on fail")
  private func fetch() {
    DropboxAPI.shared.fetchAllFiles()?
      .sink(receiveCompletion: {
        switch $0 {
        case .finished: print("Successfully finished fetch")
        case .failure(let error):
          print("Failed fetch due to \(error)")
          self.filesViewModel.handleFail(on: self) {
            DropboxAPI.shared.fetchAllFiles()?
              .sink(receiveCompletion: {_ in}, receiveValue: {
                self.filesViewModel.subject.send($0)
              }).store(in: &self.cancellables)
          }
        }
      }, receiveValue: { value in
        self.filesViewModel.subject.send(value)
      })
      .store(in: &cancellables)
  }
  
  
  private func bindViewModels() {
    filesViewModel.subject
      .sink(receiveCompletion: {_ in}) { _ in
        if self.type == .image {
          self.filesViewModel.images.forEach { [weak self] in
            self?.images.append(ItemContainer(
              imageId: $0.id,
              imageName: $0.name
            ))
          }
        } else {
          self.filesViewModel.files.forEach { [weak self] in
            self?.images.append(ItemContainer(
              imageId: $0.id,
              imageName: $0.name
            ))
          }
        }
        
      }
      .store(in: &cancellables)
    
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
    collectionView.register(FilesDetailViewCell.self, forCellWithReuseIdentifier: "\(FilesDetailViewCell.self)")
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)")
    
    view.addSubview(collectionView)
    collectionView.delegate = self
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource =  DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: ItemContainer) -> UICollectionViewCell? in
      
      if self.type == .image {
        let cell: ImageBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
        if !cell.isFethed {
          cell.fetch(id: item.imageId ?? "")
        }
        return cell
      } else if self.type == .file {
        let cell: FilesDetailViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: self.filesViewModel.files[indexPath.row].name)
        return cell
      }
      return nil
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
      view.titleLabel.text = self.type == .image ? "All Images" : "All Files"
      return view
    }
    return dataSource
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let sectionProvider = {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
      -> NSCollectionLayoutSection? in
      
      let item = LayoutManager.createItem(
        wD: .absolute(155),
        hD: .absolute(220))
      
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

extension CategoryCollectionController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let detailVC = DetailImageController()
    detailVC.title = images[indexPath.row].imageName
    guard let item = collectionView.cellForItem(at: indexPath) as? ImageBaseViewCell else { return }
    if item.isFethed {
      present(detailVC, animated: true) {
        detailVC.change(image: item.mainImageView.image)
      }
    }
  }
}
