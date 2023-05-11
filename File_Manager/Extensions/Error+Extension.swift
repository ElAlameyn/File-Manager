//
//  Error+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 04.04.2022.
//

import Foundation

extension Error {
  func getExpiredTokenStatus() -> Bool {
    if let error = self as? APIError {
      switch error {
        case .statusCode(let code):
          return code == 401 ? true : false
        default: return false
      }
    }
    return false
  }

  func convertToAPIError() -> APIError {
    self.getExpiredTokenStatus() ?
      .statusCode(401) : .undefined
  }
}
