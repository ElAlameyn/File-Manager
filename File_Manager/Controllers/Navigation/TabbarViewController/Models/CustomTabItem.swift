//
//  CustomTabItem.swift
//  File_Manager
//
//  Created by Артем Калинкин on 04.02.2022.
//

import UIKit

enum CustomTabItem: String, CaseIterable {
  case home, statistic, storage, options
}

extension CustomTabItem {
  var viewController: UIViewController {
    switch self {
    case .home:
      return UINavigationController(rootViewController: BaseViewController())
    case .statistic:
      return UINavigationController(rootViewController: StorageViewController())
    case .storage:
      return UINavigationController(rootViewController: FilesViewController())
    case .options:
      return UINavigationController(rootViewController: OptionsViewController())
    }
  }
  
  var icon: UIImage? {
    switch self {
    case .home:
      return UIImage(systemName: "house.fill",
                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))?
        .withTintColor(.white, renderingMode: .alwaysOriginal)
    case .statistic:
      return UIImage(named: "timelapse")
    case .storage:
      return UIImage(systemName: "doc.fill",
                     withConfiguration:
                      UIImage.SymbolConfiguration(pointSize: 30))?
        .withTintColor(.white, renderingMode: .alwaysOriginal)
    case .options:
      return UIImage(systemName: "wrench.fill",
                     withConfiguration:
                      UIImage.SymbolConfiguration(pointSize: 30))?
        .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
  }
  
  var name: String {
    return self.rawValue.capitalized
  }
}
