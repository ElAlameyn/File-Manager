//
//  UICollectionViewCell+Extension.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import Foundation
import UIKit

extension UICollectionView
{
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
}
