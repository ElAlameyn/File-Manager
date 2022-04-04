//
//  PaperResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 04.04.2022.
//

import Foundation

struct PaperResponse: Decodable {
  let url: String
  let resultPath: String
  let fileId: String
  let paperRevision: Int
  
  enum CodingKeys: String, CodingKey {
    case url
    case resultPath = "result_path"
    case fileId = "file_id"
    case paperRevision = "paper_revision"
  }
}
