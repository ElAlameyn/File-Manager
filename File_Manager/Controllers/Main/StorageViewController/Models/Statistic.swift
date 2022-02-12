//
//  Statistic.swift
//  File_Manager
//
//  Created by Артем Калинкин on 01.02.2022.
//

import Foundation

struct Statistic: Hashable {
  var id = UUID()
  var usedMemory: Int
  var totalMemory: Int
  
  var emptyMemory: Int {
    totalMemory - usedMemory
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Statistic, rhs: Statistic) -> Bool {
    lhs.id == rhs.id
  }
}
