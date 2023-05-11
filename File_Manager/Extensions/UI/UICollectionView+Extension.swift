//
//  UICollectionViewCell+Extension.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import Foundation
import UIKit

extension UICollectionView {
  func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
    
    guard let cell = dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as? T else { fatalError("Can't create a cell for collection view") }
    return cell
  }
  
  func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
      ofKind elementKind: String,
      for indexPath: IndexPath) -> T {
      guard let view = dequeueReusableSupplementaryView(
          ofKind: elementKind,
          withReuseIdentifier: "\(T.self)",
          for: indexPath) as? T else { fatalError("Can't create reusable view for collection view")}
        return view
      }
  
  func getSupplementaryView<T: UICollectionReusableView>(at indexPath: IndexPath) -> T {
    guard let view = self.supplementaryView(
      forElementKind: "UICollectionElementKindSectionHeader",
      at: indexPath
    ) as? T else { fatalError("Can't create supplementary view") }
    return view
  }
  
  func getCellFor<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
    guard let cell = self.cellForItem(at: indexPath) as? T else {
      fatalError("[Collection View: \(Self.self) can't find a cell of index: \(indexPath)")
    }
    return cell
  }

  func register(_ types: UICollectionViewCell.Type...) {
    types.forEach { self.register($0, forCellWithReuseIdentifier: "\($0)") }
  }

  func registerHeaderSupplementaryView(_ view: UICollectionReusableView.Type)  {
    self.register(
      view,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "\(view)"
    )
  }
  
}
