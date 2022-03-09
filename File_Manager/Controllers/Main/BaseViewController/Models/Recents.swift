//
//  Recents.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

struct ImageModel: Hashable
{
  var id = UUID()
  var image: UIImage?
  var imageName: String?

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
    lhs.id == rhs.id
  }
}
