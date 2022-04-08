//
//  Category.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

struct Category: Hashable {
  var id = UUID()
  
  var title: String
  var image: UIImage?
  var amount: Int
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Category, rhs: Category) -> Bool {
    lhs.id == rhs.id
  }
}
