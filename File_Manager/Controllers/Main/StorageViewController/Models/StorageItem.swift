//
//  StorageItem.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

enum StorageItem: Hashable, Comparable {
  
  static func < (lhs: StorageItem, rhs: StorageItem) -> Bool {
    switch lhs {
    case .statistics(_):
      return false
    case .lastModified(let value1):
      switch rhs {
      case .statistics(_):
        return false
      case .lastModified(let value2):
        if let v1 = value1, let v2 = value2  {
          return v1.title < v2.title
        }
        return false
      }
    }
  }
  
  case statistics(Statistic?)
  case lastModified(LastModifiedItem?)
}

extension StorageItem {
  
  static var allModifiedItems: [StorageItem] = [
    .lastModified(LastModifiedItem(title: "Bmage.png", image: Images.categoryImages)),
    .lastModified(LastModifiedItem(title: "Cust super big image name to show how cell fit content (okey or not).txt", image: Images.categoryFiles)),
    .lastModified(LastModifiedItem(title: "Aideo.mkv", image: Images.categoryVideos)),
  ]
  
  static let statistic: StorageItem = .statistics(Statistic(usedMemory: 25, totalMemory: 150))
  
}






