//
//  FileItem.swift
//  File_Manager
//
//  Created by Артем Калинкин on 16.03.2022.
//

import Foundation

struct FileItem {
  var id = UUID()
  var file: ListFoldersResponse.File?
}

extension FileItem: Hashable {
  static func ==(lhs: FileItem, rhs: FileItem) -> Bool {
    lhs.id == rhs.id
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
