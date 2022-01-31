//
//  StorageItem.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

enum StorageItem: Hashable {
  case statistics(Statistic?)
  case lastModified(LastModifiedItem?)
}

extension StorageItem {
  static let allModifiedItems: [StorageItem] = [
    .lastModified(LastModifiedItem(title: "item1")),
    .lastModified(LastModifiedItem(title: "item2")),
    .lastModified(LastModifiedItem(title: "item3")),
  ]
  
  static let statistic: StorageItem = .statistics(Statistic(usedMemory: 25, totalMemory: 150))
  
}

struct LastModifiedItem: Hashable {
  var id = UUID()
  var title: String
  var image: UIImage?
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: LastModifiedItem, rhs: LastModifiedItem) -> Bool {
    lhs.id == rhs.id
  }
}


struct Statistic: Hashable {
  var id = UUID()
  var usedMemory: Int
  var totalMemory: Int

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Statistic, rhs: Statistic) -> Bool {
    lhs.id == rhs.id
  }
}



