//
//  UsageSpaceResponse.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.02.2022.
//

import Foundation

struct UsageSpaceResponse {
  let used: Int
  let allocation: Allocation

  struct Allocation: Codable, Hashable {
    let tag: String
    let allocated: Int
    
    enum CodingKeys: String, CodingKey {
      case tag = ".tag"
      case allocated = "allocated"
    }
  }
}

extension UsageSpaceResponse: Codable, Hashable {
  static func == (lhs: UsageSpaceResponse, rhs: UsageSpaceResponse) -> Bool {
    return lhs.used == rhs.used
  }
}
