//
//  BaseItem.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

enum BaseItem: Hashable
{
  case title
  case category(Category?)
  case recents(RecentFile?)
}

extension BaseItem
{
  static var recentsCount = 4
  
  static var allCategories: [BaseItem] = [
    .category(Category(title: "Images", image: Images.categoryImages)),
    .category(Category(title: "Videos", image: Images.categoryVideos)),
    .category(Category(title: "Files", image: Images.categoryFiles)),
  ]
  
  static var allRecents: [BaseItem]? {
    var names = [String]()
    for number in 1...recentsCount { names.append("recent_image\(number)")}
    return names.compactMap({
      BaseItem.recents(RecentFile(image: UIImage(named: $0)))
    })
  }

}

