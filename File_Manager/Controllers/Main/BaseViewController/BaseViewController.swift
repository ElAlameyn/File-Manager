//
//  BaseViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit
import Combine

class BaseViewController: UIViewController {

  // MARK: - Typealiases
  typealias Section = LayoutManager.BaseSections
  typealias DataSource = UICollectionViewDiffableDataSource<Section, BaseItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, BaseItem>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<BaseItem>

  // MARK: - Private
  private let sections = Section.allCases
  private lazy var dataSource = configureDataSource()
  private var collectionView: UICollectionView! = nil
  private var cancellables: Set<AnyCancellable> = []
  
  private let filesViewModel = FilesViewModel()
  private let accountViewModel = CurrentAccountViewModel()
  
  private var authorizeAgain = PassthroughSubject<Void, Never>()
  
  @Limited<BaseItem>(limit: 4) private var images {
    didSet { updateImages() }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    navigationController?.navigationBar.isHidden = true
    
    configureCollectionView()
    fetch()
    bindViewModels()
    applyInitSnapshot()
  }
  
  // MARK: - Fetch & Update
  
  private func fetch() {
    // Fetch and store dropbox files
    DropboxAPI.shared.fetchAllFiles()?
      .sink(receiveCompletion: {
        switch $0 {
        case .finished: print("Successfully finished fetch")
        case .failure(let error):
          print("Failed fetch due to \(error)")
          if error.getExpiredTokenStatus() { self.authorizeAgain.send() }
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
          if error.getExpiredTokenStatus() { self.authorizeAgain.send() }
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
          self?.images.append(BaseItem.recents(ItemContainer(
            imageId: $0.id,
            imageName: $0.name
          )))
        }
      }
      .store(in: &cancellables)
    
    // Update user account
    accountViewModel.subject.sink(receiveCompletion: {_ in}) {
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
    
    authorizeAgain.sink { _ in
      let authVC = AuthViewController()
      authVC.modalPresentationStyle = .fullScreen
      self.present(authVC, animated: true)
      authVC.dismissed = {
        authVC.dismiss(animated: true)
        self.fetch()
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
  
  private func configureCollectionView() {
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

}

// MARK: - UICollectionViewDelegate

extension BaseViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch Section.allCases[indexPath.section] {
    case .title: break
    case .category:
      guard let category = Section.Category(rawValue: indexPath.row) else { return }
      switch category {
      case .images:
        let imageVC = CategoryCollectionController(type: .image)
        navigationController?.pushViewController(imageVC, animated: true)
        #warning("Make screens for videous and files")
      case .videos: break
      case .files:
        let imageVC = CategoryCollectionController(type: .file)
        navigationController?.pushViewController(imageVC, animated: true)
      }
    case .recentFiles:
      switch images[indexPath.row] {
      case .recents:
        // Handle tap on image
        let detailVC = DetailImageController()
        detailVC.configure(title: images[indexPath.row].name, indexPath: indexPath)
        detailVC.handleToolBar = self
        
        let item: ImageBaseViewCell = collectionView.getCellFor(indexPath: indexPath)
        
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

// MARK: - HandlingDetailImageToolBar

extension BaseViewController: HandlingDetailImageToolBar {
  func didTapDelete(at indexPath: IndexPath) {
    if let id = images[indexPath.row].id {
    DropboxAPI.shared.fetchDeleteFile(at: id)?
        .sink(receiveCompletion: {
          switch $0 {
          case .finished: print("[API SUCCESSFUL] - Delete file")
          case .failure(let error):
            print("[API FAIL] - Delete file:", error)
            if error.getExpiredTokenStatus() { self.authorizeAgain.send() }
          }
        }, receiveValue: {_ in
          self.updateImages()
        })
        .store(in: &cancellables)
    }
  }
}
