//
//  BaseViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import Combine
import UIKit

class BaseViewController: UIViewController {
  // MARK: Internal

  // MARK: - Typealiases

  typealias Section = LayoutManager.BaseSections
  typealias DataSource = UICollectionViewDiffableDataSource<Section, BaseItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, BaseItem>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<BaseItem>

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    navigationController?.navigationBar.isHidden = true

    configureCollectionView()
    bindViewModels()
    dataSourceManager.applyInitSnapshot()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    baseViewModel.fetch()
  }

  // MARK: Private

  private lazy var dataSourceManager = DataSourceManager(dataSource: configureDataSource())
  private let sections = Section.allCases
  private var collectionView: UICollectionView! = nil
  private var cancellables: Set<AnyCancellable> = []
  private var baseViewModel = BaseViewModel()
  private var authorizeAgain = PassthroughSubject<Void, Never>()
  @Limited<BaseItem>(limit: 4) private var images {
    didSet { dataSourceManager.updateImages(images: images) }
  }

  private func bindViewModels() {
    baseViewModel.filesSubject
      .sink { [weak self, weak baseViewModel] _ in
        guard let self else { return }
        dataSourceManager.updateFilesAmount(files: self.baseViewModel.countFilesAmount())
        self.images = baseViewModel?.baseVCImages ?? []
      }.store(in: &cancellables)

    baseViewModel.currentAccountSubject
      .sink(receiveValue: dataSourceManager.updateAccount(value:))
      .store(in: &cancellables)

    baseViewModel.authFailHandler
      .sink { [weak baseViewModel, weak self] in
        self?.handleAuth(comletion: baseViewModel?.fetch)
      }.store(in: &cancellables)
  }

  // MARK: - Collection View Setup

  private func configureCollectionView() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: LayoutManager.createBaseViewControllerLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground

    collectionView.register(
      TitleBaseViewCell.self,
      CategoryBaseViewCell.self,
      ImageBaseViewCell.self
    )

    collectionView.registerHeaderSupplementaryView(SectionHeaderBaseView.self)

    collectionView.delegate = self
    view.addSubview(collectionView)
  }

  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) {
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

      view.titleLabel.text = Section.allCases[indexPath.section].rawValue
      return view
    }
    return dataSource
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
        .sink(logInfo: "Delete File", receiveValue: { _ in
          self.dataSourceManager.updateImages(images: self.baseViewModel.baseVCImages)
        })
        .store(in: &cancellables)
    }
  }
}
