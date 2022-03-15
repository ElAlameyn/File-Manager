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
  case recents(ImageIdContainer?)
  
  var id: String? {
    switch self {
    case .recents(let optional): return optional?.imageId
    default: return nil
    }
  }
  
  var name: String? {
    switch self {
    case .recents(let optional): return optional?.imageName
    default: return nil
    }
  }

}

