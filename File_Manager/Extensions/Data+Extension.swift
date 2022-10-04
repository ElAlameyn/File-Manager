//
//  Data+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 22.02.2022.
//

import Foundation

extension Data {
  func replaceHash() -> String {
     self.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
        .trimmingCharacters(in: .whitespaces)
  }
}

