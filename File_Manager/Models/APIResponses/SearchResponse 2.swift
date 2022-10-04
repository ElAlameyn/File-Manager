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
    let metadata: ListFoldersResponse.File
    let tag: String
    
    enum CodingKeys: String, CodingKey {
      case tag = ".tag"
      case metadata
    }
  }
}

extension SearchResponse: Decodable, Hashable {
  static func == (lhs: SearchResponse, rhs: SearchResponse) -> Bool {
    lhs.matches == rhs.matches
  }
}
