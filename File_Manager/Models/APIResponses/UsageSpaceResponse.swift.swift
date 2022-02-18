//
//  UsageSpaceResponse.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.02.2022.
//

import Foundation

struct UsageSpaceResponse: Codable, Hashable {
  let used: Int
  let allocation: Allocation
  
  static func == (lhs: UsageSpaceResponse, rhs: UsageSpaceResponse) -> Bool {
    return lhs.used == rhs.used
  }

  struct Allocation: Codable, Hashable {
    let tag: String
    let allocated: Int
    
    enum CodingKeys: String, CodingKey {
      case tag = ".tag"
      case allocated = "allocated"
    }
  }
}
