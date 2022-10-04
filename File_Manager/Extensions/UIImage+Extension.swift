//
//  UIImage+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.03.2022.
//

import UIKit

extension UIImage {
  func withPointSize(_ size: CGFloat) -> UIImage {
    self.withConfiguration(UIImage.SymbolConfiguration(pointSize: size))
  }
  
  func withTintColor(_ color: UIColor) -> UIImage {
    self.withTintColor(color, renderingMode: .alwaysOriginal)
  }
}
