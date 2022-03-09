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
  
  private let filesViewModel = FilesViewModel()
  private var imagesLoader = ImagesLoader()
  private var cancellables: Set<AnyCancellable> = []
  
  private var images: [BaseItem] = [] {
    didSet {
      updateImages()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    configureCollectionView()
    bindViewModels()
    applySnapshot()
    filesViewModel.fetch()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  private func bindViewModels() {
    filesViewModel.update = { [weak self] in
      guard let self = self else { return }
      self.updateFilesAmount(
        files: self.filesViewModel.countFilesAmount()
      )
      self.filesViewModel.images.forEach {
        self.imagesLoader.fetch(path: $0.id) { [weak self] image in
          self?.images.append(BaseItem.recents(ImageModel(image: image)))
        }
      }
    }
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
//    let items = thumbnailViewModels.map { BaseItem.recents($0) }
    snapshot.append(images)
    dataSource.apply(snapshot, to: .recentFiles, animatingDifferences: true)
  }
  

  // MARK: - Collection View Setup
  private func configureCollectionView() {
    addLeftBarButtonItem()
    addRightBarButtonItem()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: LayoutManager.createBaseViewControllerLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(TitleBaseViewCell.self, forCellWithReuseIdentifier: "\(TitleBaseViewCell.self)")
    collectionView.register(CategoryBaseViewCell.self, forCellWithReuseIdentifier: "\(CategoryBaseViewCell.self)")
    collectionView.register(RecentBaseViewCell.self, forCellWithReuseIdentifier: "\(RecentBaseViewCell.self)")
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)"
    )
    
    collectionView.delegate = self
    view.addSubview(collectionView)
  }
  
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
    snapshot.appendItems([
      .category(Category(title: "Images", amount: 0)),
      .category(Category(title: "Videos", amount: 0)),
      .category(Category(title: "Files", amount: 0))
], toSection: .category)
    self.dataSource.apply(snapshot, animatingDifferences: false)
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      snapshot.appendItems([], toSection: .recentFiles)
      self?.dataSource.apply(snapshot, animatingDifferences: false)
    }
  }
  

  // MARK: - Navigation Buttons
  
  private func addLeftBarButtonItem() {
    let button = UIButton(type: .custom)
    button.setImage(Images.baseLeftItem, for: .normal)
    button.setImage(UIImage(
      systemName: "circle.grid.2x2.fill",
      withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))?
                      .withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
    button.sizeToFit()
    button.addTarget(self, action: #selector(leftBarButtonItemTapped), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
  }
  
  private func addRightBarButtonItem() {
    let button = UIButton(type: .custom)
    
    button.setImage(UIImage(
      systemName: "magnifyingglass",
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

extension BaseViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch sections[indexPath.section] {
    case .title: break
    case .category: break
      //      let detailVC =
      
      //      DropboxAPI.shared.fetchDownload(id: <#T##String?#>)
    case .recentFiles: break
      
    }
  }
}
