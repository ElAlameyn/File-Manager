//
//  ListRequestResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 08.05.2022.
//

import Foundation

struct ListRequestResponse {
  let cursor: String
  let fileRequests: [Request]
  let hasMore: Bool
  
  struct Request: Decodable {
    let id: String
    let url: String
    let title: String
    let destination: String
    let created: String
    let isOpen: Bool
    let fileCount: Int
    let description: String
    
    enum CodingKeys: String, CodingKey {
      case id, url, title, destination, created, description
      case isOpen = "is_open"
      case fileCount = "file_count"
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case fileRequests = "file_requests"
    case hasMore = "has_more"
    case cursor
  }
}
