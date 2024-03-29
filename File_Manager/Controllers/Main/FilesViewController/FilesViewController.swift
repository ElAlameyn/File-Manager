//
//  StatisticViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 05.02.2022.
//

import UIKit
import Combine
import BLTNBoard

class FilesViewController: UIViewController {
  
  typealias Section = LayoutManager.FilesSections
  typealias DataSource = UICollectionViewDiffableDataSource<Section, FileItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FileItem>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<FileItem>
  

  private let filesViewModel = FilesViewModel()
  private var collectionView: UICollectionView! = nil
  private lazy var dataSource = configureDataSource()
  private var cancellables: Set<AnyCancellable> = []
  
  private var authorizeAgain = PassthroughSubject<Void, Never>()
  private var reloadFiles = PassthroughSubject<String, Never>()
  
  private var documentPicker = DocumentPicker()
  private let searchController = UISearchController()
  
  private var path = Path()
  private var isRootFolder: Bool {
    path.current == ""
  }

  private var uploadButton = UIButton.withStyle({
    $0.setTitle("", for: .normal)
    $0.setImage(UIImage(systemName: "icloud.and.arrow.up")?.withPointSize(30).withTintColor(.white), for: .normal)
    $0.setBackgroundImage(UIImage(systemName: "circle.fill")?.withPointSize(60), for: .normal)
    $0.setTitleShadowColor(.black, for: .normal)
    Style.withShadow(withRadius: 3, offset: CGSize(width: 0, height: 0), opacity: 0.3)($0)
    }
  )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    title = "Files"
    
    configureSearchController()
    configureCollectionView()
    
    configUploadButton()
    
    bindViewModels()
    initSnaphot()
    
    reloadFiles.send(self.path.current)
  }
  
  private func configUploadButton() {
    view.addSubview(uploadButton)
    
    uploadButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      uploadButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
      uploadButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
    ])
    
    uploadButton.addTarget(self, action: #selector(didTapUploadButton), for: .touchUpInside)

  }
  
  @objc func didTapUploadButton() {
    let picker = documentPicker.picker()
    self.present(picker, animated: true)
  }

  
  private func configureSearchController() {
    searchController.searchBar.sizeToFit()
    searchController.searchBar.delegate = self
    navigationItem.titleView = searchController.searchBar
    
    searchController.searchBar.placeholder = "Find files you want"
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchResultsUpdater = self
  }

  // MARK: - Fetch & Update Data
  
  private func bindViewModels() {
    // Observe files changes and call update
    filesViewModel.subject
      .sink(receiveCompletion: {
        $0.debugCompletion(descr: "Reload Files", subject: self.authorizeAgain)
      }) { files in
        self.update(files: files?.entries, updateLastModified: true)
      }
      .store(in: &cancellables)
    
    // Handle token expiration
    authorizeAgain.sink { _ in
      let authVC = AuthViewController()
      authVC.modalPresentationStyle = .fullScreen
      self.present(authVC, animated: true)
      authVC.dismissed = {
        authVC.dismiss(animated: true)
        self.reloadFiles.send(self.path.current)
      }
    }
    .store(in: &cancellables)
    
    reloadFiles
      .compactMap { path -> AnyPublisher<ListFoldersResponse?, Error>? in
        return DropboxAPI.shared.fetchAllFiles(path: path, recursive: false)
      }
      .switchToLatest()
      .sink(receiveCompletion: {
        $0.debugCompletion(descr: "Reload files", subject: self.authorizeAgain)
      }) {
        self.filesViewModel.subject.send($0)
      }
      .store(in: &cancellables)
    
    documentPicker.document
      .sink { document in
        document?.open(completionHandler: { sucess in
          if sucess {
            guard let document = document else { return }
            guard let data = document.data else { return }
            let fileName = document.localizedName
            let extenstion = document.fileURL.pathExtension
            
            DropboxAPI.shared.fetchUpload(path: self.path.current + "/\(fileName).\(extenstion)", fileData: data)?
              .sink(receiveCompletion: {
                $0.debugCompletion(descr: "Upload Document", subject: self.authorizeAgain)
              }, receiveValue: { _ in
                self.reloadFiles.send(self.path.current)
              })
              .store(in: &self.cancellables)
          }
          }
        )
      }
        .store(in: &cancellables)
  }

  private func initSnaphot() {
    var snapshot = Snapshot()
    snapshot.appendSections([.lastModified, .main])
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func update(files: [ListFoldersResponse.File]?, updateLastModified: Bool? = false) {
    var mainSnapshot = SectionSnapshot()
    var modifiedSnapshot = SectionSnapshot()
    if let storages = files?.compactMap({ FileItem(file: $0) }) {
      if !isRootFolder {
        var updated = [FileItem()]
        updated += storages
        mainSnapshot.append(updated)
      } else {
        mainSnapshot.append(storages)
      }
      self.dataSource.apply(mainSnapshot, to: .main, animatingDifferences: true)
    }
    
    guard updateLastModified! else { return }
    
    @Limited<FileItem>(limit: 4) var modified
    self.filesViewModel.filteredByDateModified().forEach {
      modified.append(FileItem(file: $0))
    }
    
    modifiedSnapshot.append(modified)
    dataSource.apply(modifiedSnapshot, to: .lastModified, animatingDifferences: true)
  }
}

// MARK: - Collection View

extension FilesViewController {
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: LayoutManager.createFilesViewLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = Colors.baseBackground
    collectionView.register(FileItemCell.self, forCellWithReuseIdentifier: "\(FileItemCell.self)")
    collectionView.register(LastModifiedCell.self, forCellWithReuseIdentifier: "\(LastModifiedCell.self)")
    collectionView.register(ReturnFileCell.self, forCellWithReuseIdentifier: "\(ReturnFileCell.self)")
    
    collectionView.register(
      SectionHeaderBaseView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(SectionHeaderBaseView.self)")
    
    collectionView.register(
      FoldersHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(FoldersHeaderView.self)")
    
    collectionView.delegate = self
    view.addSubview(collectionView)
  }
  
  private func configureDataSource() -> DataSource {
    let dataSource = DataSource(collectionView: collectionView) { [self]
      (collectionView: UICollectionView, indexPath: IndexPath, item: FileItem) -> UICollectionViewCell? in
      
      guard let section = Section(rawValue: indexPath.section) else { return nil }
      switch section {
      case .lastModified:
        let cell: LastModifiedCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(title: item.file?.name, tag: item.file?.tag)
        return cell
      case .main:
        if !isRootFolder {
          if indexPath.row == 0 && indexPath.section == 1 {
            let cell: ReturnFileCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell
          }
        }
        let cell: FileItemCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.handleMenu = self
        cell.indexPath = indexPath
        cell.configure(title: item.file?.name, tag: item.file?.tag)
        return cell
      }
    }
    
    dataSource.supplementaryViewProvider = {
      collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      switch Section(rawValue: indexPath.section) {
      case .lastModified:
        let view: SectionHeaderBaseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        view.titleLabel.text = Texts.fileSectionLastModified
        return view
      case .main:
        let view: FoldersHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        view.titleLabel.text = Texts.fileSectionAllFiles
        view.delegate = self
        return view
      default: return nil
      }
    }
    return dataSource
  }
  
}

// MARK: - UICollectionViewDelegate

extension FilesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch LayoutManager.FilesSections.allCases[indexPath.section] {
    case .lastModified: break
    case .main:
      // Handle back arrow tap
      if indexPath.row == 0 && indexPath.section == 1  && !isRootFolder {
        reloadFiles.send(self.path.getPrevious ?? "")
        
        // Change show path label
        let view: FoldersHeaderView = collectionView.getSupplementaryView(at: IndexPath(row: 0, section: 1))
        view.currentPathLabel.text = self.path.wasPrevious
        return
      }
      
      // Handle tap on folder
      let selected = isRootFolder ? filesViewModel.allFiles[indexPath.row] : filesViewModel.allFiles[indexPath.row - 1]
      if selected.tag == "folder" {
        guard let path = selected.pathDisplay else { return }
        self.path.current = path
        let view: FoldersHeaderView = collectionView.getSupplementaryView(at: IndexPath(row: 0, section: 1))
        view.currentPathLabel.text = self.path.current
        reloadFiles.send(self.path.current)
      }
    }
  }
}


// MARK: - UISearchResultsUpdating & UISearchBarDelegate

extension FilesViewController: UISearchResultsUpdating, UISearchBarDelegate {
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.text = ""
    searchBar.resignFirstResponder()
    self.reloadFiles.send("")
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    let textField = searchController.searchBar.searchTextField
    
    textField.publisher(for: .editingChanged)
      .map { textField.text ?? "" }
      .sink { text in
        if !text.isEmpty {
          DropboxAPI.shared.fetchSearch(q: text)?
            .sink(receiveCompletion: {
              $0.debugCompletion(descr: "Search file", subject: self.authorizeAgain)
            }, receiveValue: { data in
              let files = data?.matches.compactMap { $0.metadata.metadata }
              self.update(files: files)
            })
            .store(in: &self.cancellables)
        }
      }
      .store(in: &cancellables)
  }
}

// MARK: - HandlingFileMenuOperations

extension FilesViewController: HandlingFileMenuOperations {
  func didShareTapped(for indexPath: IndexPath) {
  }
  
  func didMoveToTapped(for indexPath: IndexPath) {
  }
  
  func didCopyToTapped(for indexPath: IndexPath) {
  }
  
  func didDeleteTapped(for indexPath: IndexPath) {
    let currentIndex = isRootFolder ? indexPath.row : indexPath.row - 1
    DropboxAPI.shared.fetchDeleteFile(
      at: filesViewModel.allFiles[currentIndex].pathDisplay ?? ""
    )?
      .sink(receiveCompletion: {
          $0.debugCompletion(descr: "Delete file", subject: self.authorizeAgain)
      }, receiveValue: {_ in
        self.reloadFiles.send(self.path.current)
      })
      .store(in: &cancellables)
  }
}

// MARK: - HandlingFolderView

extension FilesViewController: HandlingFolderView {
  func addFolder() {
    let paper = TextFieldBulletinPage.cretateTextFieldBulletin(title: "Add Folder")
    let manager = BLTNItemManager(rootItem: paper)
    manager.showBulletin(above: self)
    
    paper.actionHandler = { _ in
      guard let text = paper.textField.text else { return }
      DropboxAPI.shared.fetchCreateFolder(with: text, at: self.path.current)?
        .sink(receiveCompletion: {
          $0.debugCompletion(descr: "Create folder", subject: self.authorizeAgain)
        }, receiveValue: {_ in
          self.reloadFiles.send(self.path.current)
        })
        .store(in: &self.cancellables)
      
      manager.dismissBulletin()
    }
    
  }
  
  func addPaper() {
    let paper = TextFieldBulletinPage.cretateTextFieldBulletin(title: "Add Paper")
    let manager = BLTNItemManager(rootItem: paper)
    manager.showBulletin(above: self)
    
    #warning("Add redirect to paper created url")
    paper.actionHandler = { _ in
      guard let text = paper.textField.text else { return }
      DropboxAPI.shared.fetchCreatePaper(with: text, at: self.path.current)?
        .sink(receiveCompletion: {
          $0.debugCompletion(descr: "Create paper", subject: self.authorizeAgain)
        }, receiveValue: { value in
          self.reloadFiles.send(self.path.current)
        })
        .store(in: &self.cancellables)
      
      manager.dismissBulletin()
    }
  }
}

