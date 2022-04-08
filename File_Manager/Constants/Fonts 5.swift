//
//  Fonts.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit

struct Fonts
{
  
  static var robotoLight: UIFont {
    UIFont(name: "Roboto-Light", size: 18) ?? .preferredFont(forTextStyle: .body)
  }
  
  static var robotoMedium: UIFont {
    UIFont(name: "Roboto-Medium", size: 30) ?? .preferredFont(forTextStyle: .body)
  }
  
  static var robotoMediumForCategories: UIFont {
    UIFont(name: "Roboto-Medium", size: 14) ?? .preferredFont(forTextStyle: .body)
  }
  
  static var robotoRegular: UIFont {
    UIFont(name: "Roboto-Regular", size: 24) ?? .preferredFont(forTextStyle: .body)
  }
  
  static var robotoBold: UIFont {
    UIFont(name: "Roboto-Bold", size: 30) ?? .preferredFont(forTextStyle: .body)
  }
}
