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
  case recents(ImageModel?)
}

