//
//  Limited.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.03.2022.
//

import Foundation

@propertyWrapper
struct Limited<T> {
  internal init(limit: Int) {
    self.limit = limit
  }
  
  private let limit: Int
  private var stored: [T] = []

  var wrappedValue: [T] {
    get { return stored }
    set {
      if stored.count < limit {
        stored = newValue
      }
    }
  }
}

