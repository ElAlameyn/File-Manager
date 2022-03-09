//
//  Publiser+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 07.03.2022.
//

import Combine
import Foundation

enum APIError: Error {
  case invalidResponse
  case statusCode(Int)
}

fileprivate typealias DataTaskResult = (data: Data, response: URLResponse)

extension Publisher {
  func validate(_ data: Data, _ response: URLResponse) throws -> Data {
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.invalidResponse
    }
    
    guard httpResponse.statusCode != 401 else {
      throw APIError.statusCode(httpResponse.statusCode)
    }
     
    return data
  }
}
