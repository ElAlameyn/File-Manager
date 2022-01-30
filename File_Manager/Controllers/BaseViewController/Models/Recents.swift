//
//  Recents.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

struct RecentFile: Hashable {
  var id = UUID()
  var image: UIImage?
  var files: String?
  var videos: String?
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: RecentFile, rhs: RecentFile) -> Bool {
    lhs.id == rhs.id
  }
}
