//
//  UsageSpaceResponse.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.02.2022.
//

import Foundation

struct UsageSpaceResponse: Decodable {
  
  struct Allocation: Decodable {
    let tag: String
    let allocated: Int
  }
  
  let used: Int
  let allocation: Allocation
}
