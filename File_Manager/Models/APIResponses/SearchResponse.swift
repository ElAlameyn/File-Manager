//
//  SearchResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 16.03.2022.
//

import Foundation


struct SearchResponse {
  let matches: [Metadata]
  
  struct Metadata: Decodable, Hashable {
    let metadata: FileMetadata
  }
  
  struct FileMetadata: Decodable & Hashable {
    let metadata: File
    let tag: String
    
    enum CodingKeys: String, CodingKey {
      case tag = ".tag"
      case metadata
    }
  }

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

extension SearchResponse: Decodable, Hashable {
  static func == (lhs: SearchResponse, rhs: SearchResponse) -> Bool {
    lhs.matches == rhs.matches
  }
}
