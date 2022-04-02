//
//  BaseViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
  
  typealias Section = LayoutManager.BaseSections
  typealias DataSource = UICollectionViewDiffableDataSource<Section, BaseItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, BaseItem>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<BaseItem>
  
  private let sections = Section.allCases
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  private var cancellables: Set<AnyCancellable> = []
  
  private let filesViewModel = FilesViewModel()
  private let accountViewModel = CurrentAccountViewModel()
  
  @Limited<BaseItem>(limit: 4) private var images {
    didSet {
      updateImages()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    #warning("Fix navigation bar thing")
    navigationController?.navigationBar.isHidden = true
    
    configureCollectionView()
    fetch()
    bindViewModels()
    applyInitSnapshot()
  }
  
  private func fetch() {
    // Fetch and store dropbox files
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
    
    // Fetch and store account info
    DropboxAPI.shared.fetchCurrentAccount()?
      .sink(receiveCompletion: {
        switch $0 {
        case .finished: print("SUCCESS ACCOUNT FETCH")
        case .failure(let error):
          print("FAIL ACCOUNT FETCH ", error)
          self.filesViewModel.handleFail(on: self) {
            DropboxAPI.shared.fetchCurrentAccount()?
              .sink(receiveCompletion: {_ in}, receiveValue: {
                self.accountViewModel.subject.send($0)
              }).store(in: &self.cancellables)
          }
        }
      }, receiveValue: {
        self.accountViewModel.subject.send($0)
      })
      .store(in: &cancellables)
  }
  
  private func bindViewModels() {
    // Update files
    filesViewModel.subject
      .sink(receiveCompletion: {_ in}) { _ in
        self.updateFilesAmount(
          files: self.filesViewModel.countFilesAmount()
        )
        self.filesViewModel.images.forEach { [weak self] in
          self?.images.append(BaseItem.recents(ImageIdContainer(
            imageId: $0.id,
            imageName: $0.name
          )))
        }
      }
      .store(in: &cancellables)
    
    // Update user account
    accountViewModel.subject.sink(receiveCompletion: {_ in}) {
      print("ACCOUNT RESPONSE ", $0.debugDescription)
      guard let value = $0, let url = URL(string: value.profilePhotoURL ?? "") else { return }
      if let data = try? Data(contentsOf: url) {
        if let image = UIImage(data: data) {
          self.updateAccount(
            image: image,
            title:"Welcome, " + ($0?.name.displayName ?? "User")
          )
        }
      }
    }.store(in: &cancellables)
  }
  
  private func updateAccount(image: UIImage? = nil, title: String? = nil) {
    var snapshot = SectionSnapshot()
    snapshot.append([.title(image: image, text: title)])
    dataSource.apply(snapshot, to: .title, animatingDifferences: true)
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
    snapshot.append(images)
    dataSource.apply(snapshot, to: .recentFiles, animatingDifferences: true)
  }
  
  
  // MARK: - Collection View Setup
  
  private func configureDataSource() -> DataSource {
    let dataSource =  DataSource(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: BaseItem) -> UICollectionViewCell? in
      
      switch item {
      case .title(let image, let text):
        let cell: TitleBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(image: image, text: text)
        return cell
      case .category(let category):
        let cell: CategoryBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: category?.title, amount: category?.amount)
        return cell
      case .recents(let model):
        let cell: ImageBaseViewCell = collectionView.dequeueReusableCell(for: indexPath)
        if !cell.isFethed {
          cell.fetch(id: model?.imageId ?? "")
        }
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
      case .recentFiles:
        view.titleLabel.text = "Recent Images"
      default: break
      }
      return view
    }
    return dataSource
  }
  
  private func applyInitSnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.title, .category, .recentFiles])
    snapshot.appendItems( [.title(image: nil, text: nil)] , toSection: .title)
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
    button.setImage(UIImage(systemName: "circle.grid.2x2.fill")?
      .withTintColor(.black).withPointSize(70), for: .normal)
    button.addTarget(self, action: #selector(leftBarButtonItemTapped), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
  }
  
  private func addRightBarButtonItem() {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "magnifyingglass")?
      .withTintColor(.black).withPointSize(25), for: .normal)
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

extension BaseViewController {
  private func configureCollectionView() {
    addLeftBarButtonItem()
    addRightBarButtonItem()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: LayoutManager.createBaseViewControllerLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(TitleBaseViewCell.self, forCellWithReuseIdentifier: "\(TitleBaseViewCell.self)")
    collectionView.register(CategoryBaseViewCell.self, forCellWithReuseIdentifier: "\(CategoryBaseViewCell.self)")
    collectionView.register(ImageBaseViewCell.self, forCellWithReuseIdentifier: "\(ImageBaseViewCell.self)")
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)"
    )
    
    collectionView.delegate = self
    view.addSubview(collectionView)
    
  }
}

extension BaseViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch sections[indexPath.section] {
    case .title: break
    case .category:
      guard let category = Section.Category(rawValue: indexPath.row) else { return }
      switch category {
      case .images:
        let imageVC = ImagesCollectionController()
        navigationController?.pushViewController(imageVC, animated: true)
        #warning("Make screens for videous and files")
      case .videos: break
      case .files: break
      }
    case .recentFiles:
      switch images[indexPath.row] {
      case .recents:
        // Handle tap on image
        let detailVC = DetailImageController()
        detailVC.title = images[indexPath.row].name
        guard let item = collectionView.cellForItem(at: indexPath) as? ImageBaseViewCell else { return }
        if item.isFethed {
          navigationController?.pushViewController(detailVC, animated: true, completion: {
            detailVC.change(image: item.mainImageView.image)
          })
        }
      default: break
      }
    }
  }
}
