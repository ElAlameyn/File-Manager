//
//  Recents.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

struct ImageIdContainer: Hashable
{
  var id = UUID()
  var imageId: String?
  var imageName: String?

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: ImageIdContainer, rhs: ImageIdContainer) -> Bool {
    lhs.id == rhs.id
  }
}
