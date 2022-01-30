//
//  BaseItem.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import Foundation

enum BaseItem: Hashable {
  case title
  case category(Category?)
  case recents(RecentFile?)
}

extension BaseItem {
  static var allCategories: [BaseItem] = [
    .category(Category(title: "Images")),
    .category(Category(title: "Videos")),
    .category(Category(title: "Files"))
  ]
}

