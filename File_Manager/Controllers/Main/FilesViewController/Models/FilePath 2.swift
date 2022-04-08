//
//  Path.swift
//  File_Manager
//
//  Created by Артем Калинкин on 29.03.2022.
//

import Foundation

/// Struct for displaing folder path
extension FilesViewController {
  struct Path {
    var wasPrevious: String?
    var all = [String]()
    
    var current: String {
      get {
        all.last ?? ""
      }
      set {
        wasPrevious = current
        all.append(newValue)
      }
    }
    
    var getPrevious: String? {
      mutating get {
        all.removeLast()
        wasPrevious = all.last
        return wasPrevious
      }
      set {
        wasPrevious = newValue
      }
    }
  }
}
