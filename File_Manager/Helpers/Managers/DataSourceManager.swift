//
//  DataSourceManager.swift
//  File_Manager
//
//  Created by Артем Калинкин on 23.04.2023.
//

import UIKit

struct DataSourceManager<Section: Hashable, Item: Hashable> {
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>
}

// MARK: - BaseViewController
extension DataSourceManager
where
Section == LayoutManager.BaseSections,
Item == BaseItem {
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<BaseItem>


  func updateAccount(value: CurrentAccountResponse?) {
    guard let value, let url = URL(string: value.profilePhotoURL ?? "") else { return }
    if let data = try? Data(contentsOf: url) {
      if let image = UIImage(data: data) {
        var snapshot = SectionSnapshot()
        snapshot.append([
          .title(
            image: image,
            text: "Welcome, " + value.name.displayName
          )])
        dataSource.apply(snapshot, to: .title, animatingDifferences: true)
      }
    }
  }

  func updateFilesAmount(files: (images: Int, videos: Int, files: Int)) {
    var snapshot = SectionSnapshot()
    snapshot.append([
      .category(Category(title: "Images", amount: files.images)),
      .category(Category(title: "Videos", amount: files.videos)),
      .category(Category(title: "Files", amount: files.files))
    ])
    dataSource.apply(snapshot, to: .category, animatingDifferences: true)
  }

  func updateImages(images: [BaseItem]) {
    var snapshot = SectionSnapshot()
    snapshot.append(images)
    dataSource.apply(snapshot, to: .recentFiles, animatingDifferences: true)
  }

  func applyInitSnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, BaseItem>()
    snapshot.appendSections([.title, .category, .recentFiles])
    snapshot.appendItems( [.title(image: nil, text: nil)] , toSection: .title)
    snapshot.appendItems([
      .category(Category(title: "Images", amount: 0)),
      .category(Category(title: "Videos", amount: 0)),
      .category(Category(title: "Files", amount: 0))
    ], toSection: .category)
    dataSource.apply(snapshot, animatingDifferences: false)

    DispatchQueue.global(qos: .userInitiated).async {
      snapshot.appendItems([], toSection: .recentFiles)
      dataSource.apply(snapshot, animatingDifferences: false)
    }
  }

}
