//
//  ResponseType.swift
//  File_Manager
//
//  Created by Артем Калинкин on 14.02.2022.
//

import Foundation

enum ResponseConfig {
  
  enum Method: String {
    case get = "GET"
    case post = "POST"
  }
  
  enum Users: String {
    case usageSpace = "/get_space_usage"
  }
  
  private struct TokenCredentials {
    static let clientID = "688rvrlb7upz9jb"
    static let clientSecret = "2zb3cvcxd9e7a2s"
    static let redirectURI = "http://localhost"
  }
  
  case token(String)
  case users(Users)

  var baseURL: String { "https://api.dropboxapi.com" }

  var configuredURL: String {
    switch self {
    case .token:
      return baseURL + "/oauth2/token"
    case .users(let user):
      let startPoint = baseURL + "/2/users"
      switch user {
      case .usageSpace:
        return startPoint + user.rawValue
      }
    }
  }
  
  var components: [String: String]? {
    switch self {
    case .token(let code):
      return ["grant_type": "authorization_code",
              "code": code,
              "redirect_uri": TokenCredentials.redirectURI]
    case .users(let users):
      switch users {
      case .usageSpace: return nil
      }
    }
  }
  
  func setHeaders(for request: inout URLRequest) {
    switch self {
    case .token:
      request.setValue("Basic \("\(TokenCredentials.clientID):\(TokenCredentials.clientSecret)".toBase64())",
                       forHTTPHeaderField: "Authorization")
      request.setValue("application/x-www-form-urlencoded",
                       forHTTPHeaderField: "Content-Type")
      // For PCKE extension
      //      URLQueryItem(name: "client_id", value: AuthViewController.Const.clientID),
      //      URLQueryItem(name: "code_verifier", value: code)
    case .users: return
    }
  }

  var method: Method {
    switch self {
    case .token, .users:
      return .post
    }
  }
  
}
