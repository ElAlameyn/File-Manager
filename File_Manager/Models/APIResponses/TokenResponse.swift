//
//  TokenResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.02.2022.
//

import Foundation

struct TokenResponse: Codable {

  var date = Date()
  let accessToken: String
  let expiresIn: Int
  let refreshToken: String?
  let tokenType: String

  var isValid: Bool {
    Date().timeIntervalSince(date) < TimeInterval(expiresIn)
  }

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case tokenType = "token_type"
  }
}
