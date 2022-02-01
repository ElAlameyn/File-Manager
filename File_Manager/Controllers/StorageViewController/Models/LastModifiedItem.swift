//
//  LastModifiedItem.swift
//  File_Manager
//
//  Created by Артем Калинкин on 01.02.2022.
//

import UIKit

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
