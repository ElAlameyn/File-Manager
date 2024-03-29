//
//  BaseItem.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

enum BaseItem: Hashable {
  case title(image: UIImage?, text: String? = "")
  case category(Category?)
  case recents(ItemContainer?)
}

extension BaseItem {
  
  // Access properties for recents section
  
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

