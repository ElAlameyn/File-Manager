//
//  ListFoldersResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.02.2022.
//

import Foundation

struct ListFoldersResponse: Decodable, Hashable {
  
  static func == (lhs: ListFoldersResponse, rhs: ListFoldersResponse) -> Bool {
    lhs.entries == rhs.entries
  }

  var entries: [File]

  struct File: Decodable, Hashable {
    let tag: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
      case tag = ".tag"
      case name = "name"
    }
  }
  
}
