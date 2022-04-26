//
//  UIButton+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 06.02.2022.
//

import UIKit
import Combine

extension UIButton {
  static func withStyle(_ f: @escaping (UIButton) -> Void) -> UIButton {
    let button = UIButton()
    f(button)
    return button
  }
}


