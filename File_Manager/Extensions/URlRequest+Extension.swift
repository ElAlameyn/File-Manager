//
//  URlRequest+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.03.2022.
//

import Foundation

extension URLRequest {
  mutating func add(token: String) {
      self.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  }
}
