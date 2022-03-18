//
//  APIError.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.03.2022.
//

import Foundation

enum APIError: Error {
  case invalidResponse
  case statusCode(Int)
}
