//
//  BaseViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
  
  enum Section: Int {
    case title, category, recentFiles
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, BaseItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, BaseItem>
  
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<BaseItem>
  
  private let sections: [Section] = [.title, .category, .recentFiles]
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  
  private let listFoldersViewModel = ListFoldersViewModel()
  private var thumbnailViewModels = [ThumbnailViewModel]()
  private var cancellables: Set<AnyCancellable> = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    configureUI()
    bindViewModels()
    applySnapshot()
  }
  
  private func bindViewModels() {
    listFoldersViewModel.$value
      .sink(receiveValue: {[weak self] response in
        guard let self = self else { return }
        response?.files.forEach {
          let viewModel = ThumbnailViewModel()
          viewModel.fetch(path: $0.pathDisplay)
          self.thumbnailViewModels.append(viewModel)
        }
        self.updateFilesAmount(files: self.listFoldersViewModel.countFilesAmount(value: response))
      })
      .store(in: &cancellables)
    
    thumbnailViewModels.forEach {
      $0.$image
        .sink { image in
          print("image: \(image)")
        }
        .store(in: &cancellables)
    }

//    thumbnailViewModel.$image
//      .sink { [weak self] value in
//        guard let self = self else { return }
//        let imageView = UIImageView(image: value)
//      }
  }
  
  private func updateFilesAmount(files: (images: Int, videos: Int, files: Int)) {
    var snapshot = SectionSnapshot()
    snapshot.append([
        .category(Category(title: "Images", amount: files.images)),
        .category(Category(title: "Videos", amount: files.videos)),
        .category(Category(title: "Files", amount: files.files))
      ])
    dataSource.apply(snapshot, to: .category, animatingDifferences: true)
  }
  
  private func updateImages() {
    var snapshot = SectionSnapshot()
    let items = thumbnailViewModels.map { BaseItem.recents($0) }
    snapshot.append(items)
    dataSource.apply(snapshot, to: .recentFiles, animatingDifferences: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    listFoldersViewModel.fetch()
  }
  
  // MARK: - Data Source
  
  private func configureDataSource() -> DataSource {
    let dataSource =  DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: BaseItem) -> UICollectionViewCell? in
      
      switch item {
      case .title:
        let cell: TitleBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
        return cell
      case .category(let category):
        let cell: CategoryBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: category?.title, amount: category?.amount)
        return cell
      case .recents(let model):
        let cell: RecentBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(image: model?.image)
        return cell
      }
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
      
      switch Section(rawValue: indexPath.section) {
      case .category:
        view.titleLabel.text = "Category"
      case .title:
        break
      case .recentFiles:
        view.titleLabel.text = "Recent Files"
      case .none:
        break
      }
      return view
    }
    return dataSource
  }
  
  private func applySnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.title, .category, .recentFiles])
    snapshot.appendItems( [.title] , toSection: .title)
    snapshot.appendItems([], toSection: .category)
    self.dataSource.apply(snapshot, animatingDifferences: false)
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      snapshot.appendItems([], toSection: .recentFiles)
      self?.dataSource.apply(snapshot, animatingDifferences: false)
    }
  }
  
  // MARK: - Collection View Setup
  
  private func configureUI() {
    addLeftBarButtonItem()
    addRightBarButtonItem()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(TitleBaseViewCell.self, forCellWithReuseIdentifier: "\(TitleBaseViewCell.self)")
    collectionView.register(CategoryBaseViewCell.self, forCellWithReuseIdentifier: "\(CategoryBaseViewCell.self)")
    collectionView.register(RecentBaseViewCell.self, forCellWithReuseIdentifier: "\(RecentBaseViewCell.self)")
    
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
      case .title:
        let item = LayoutManager.createItem(
          wD: .fractionalWidth(1.0),
          hD: .fractionalHeight(1.0))
        
        let group = LayoutManager.createHorizontalGroup(
          wD: .fractionalWidth(1.0),
          hD: .estimated(120),
          item: item)
        
        return NSCollectionLayoutSection(group: group)
        
      case .category:
        let item = LayoutManager.createItem(
          wD: .fractionalWidth(1.0),
          hD: .fractionalHeight(1.0))
        
        let group = LayoutManager.createHorizontalGroup(
          wD: .estimated(130),
          hD: .estimated(150),
          item: item)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 10)
        section.interGroupSpacing = 20
        
        // Supplementary header view setup
        let sectionHeader = LayoutManager.createSectionHeader(
          wD: .fractionalWidth(1.0),
          hD: .estimated(30))
        
        section.boundarySupplementaryItems = [sectionHeader]
        return section
        
      case .recentFiles:
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
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
  
  // MARK: - Navigation Buttons
  
  private func addLeftBarButtonItem() {
    let button = UIButton(type: .custom)
    button.setImage(Images.baseLeftItem, for: .normal)
    button.setImage(UIImage(systemName: "circle.grid.2x2.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))?
                      .withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
    button.sizeToFit()
    
    button.addTarget(self, action: #selector(leftBarButtonItemTapped), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
  }
  
  private func addRightBarButtonItem() {
    let button = UIButton(type: .custom)
    
    button.setImage(UIImage(systemName: "magnifyingglass",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))?
                      .withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
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
