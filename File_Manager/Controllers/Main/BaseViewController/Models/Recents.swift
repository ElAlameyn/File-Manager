//
//  Recents.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

struct ItemContainer {
  var id = UUID()
  var imageId: String?
  var imageName: String?
}

extension ItemContainer: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: ItemContainer, rhs: ItemContainer) -> Bool {
    lhs.id == rhs.id
  }
}
