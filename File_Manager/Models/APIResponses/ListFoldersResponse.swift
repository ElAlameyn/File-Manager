//
//  ListFoldersResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.02.2022.
//

import Foundation

struct ListFoldersResponse
{
  var entries: [File]

  struct File: Decodable, Hashable {
    let tag: String
    let name: String
    let clientModified: String?
    
    enum CodingKeys: String, CodingKey {
      case tag = ".tag"
      case name = "name"
      case clientModified = "client_modified"
    }
  }
}

extension ListFoldersResponse: Decodable, Hashable {
  static func == (lhs: ListFoldersResponse, rhs: ListFoldersResponse) -> Bool {
    lhs.entries == rhs.entries
  }
}

extension ListFoldersResponse {
  
  func filteredByDateModified(inverse: Bool? = false) -> [ListFoldersResponse.File] {
    var filtered = entries.filter { $0.tag == "file"}
    let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    if !(inverse!) {
      filtered.sort {
        if let date1 = $0.clientModified?.toDate(dateFormat: dateFormat),
           let date2 = $1.clientModified?.toDate(dateFormat: dateFormat) {
          return date1 > date2
        }
        return false
      }
    } else {
      filtered.sort {
        if let date1 = $0.clientModified?.toDate(dateFormat: dateFormat),
           let date2 = $1.clientModified?.toDate(dateFormat: dateFormat) {
          return date1 < date2
        }
        return false
      }
    }
    return filtered
  }

}
