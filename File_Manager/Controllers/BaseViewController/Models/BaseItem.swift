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
    .category(Category(title: "Images", image: Images.categoryImages)),
    .category(Category(title: "Videos", image: Images.categoryVideos)),
    .category(Category(title: "Files", image: Images.categoryFiles)),
  ]
  
  static var allRecents: [BaseItem] = [
    .recents(RecentFile(image: Images.recentImage1)),
    .recents(RecentFile(image: Images.recentImage2)),
    .recents(RecentFile(image: Images.recentImage3)),
    .recents(RecentFile(image: Images.recentImage4))
  ]
}

