//
//  ListFoldersResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.02.2022.
//

import Foundation

struct ListFoldersResponse {
  let entries: [File]

  struct File: Decodable, Hashable {
    let tag: String
    let name: String
    let id: String
    let clientModified: String?
    let pathDisplay: String?
    
    enum CodingKeys: String, CodingKey {
      case tag = ".tag"
      case name = "name"
      case clientModified = "client_modified"
      case pathDisplay = "path_display"
      case id
    }
  }
}

extension ListFoldersResponse: Decodable, Hashable {
  static func == (lhs: ListFoldersResponse, rhs: ListFoldersResponse) -> Bool {
    lhs.entries == rhs.entries
  }
}

