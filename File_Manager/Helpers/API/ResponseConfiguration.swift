//
//  ResponseType.swift
//  File_Manager
//
//  Created by Артем Калинкин on 14.02.2022.
//

import Foundation
import KeychainSwift

enum RequestConfigurator {
  
  enum Method: String {
    case get = "GET"
    case post = "POST"
  }
  
  enum Users: String {
    case usageSpace = "/get_space_usage"
  }
  
  enum Files: String {
    case listAllFolders = "/list_folder"
  }
  
  private struct TokenCredentials {
    static let clientID = "688rvrlb7upz9jb"
    static let clientSecret = "2zb3cvcxd9e7a2s"
    static let redirectURI = "http://localhost"
  }
  
  case token(String)
  case users(Users)
  case files(Files)

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
    case .files(let type):
      let startPoint = baseURL + "/2/files"
      switch type {
      case .listAllFolders:
        return startPoint + type.rawValue
      }
    }
  }
  
  private var components: [String: Any]? {
    switch self {
    case .token(let code):
      return ["grant_type": "authorization_code",
              "code": code,
              "redirect_uri": TokenCredentials.redirectURI]
    case .users: return nil
    case .files(let type):
      switch type {
      case .listAllFolders:
        return ["path": "",
                "recursive": true
        ]
      }
    }
  }
  
//  var requestComponents: URLComponents {
//    var components = URLComponents()
//    components.queryItems = self.components?.compactMap({ (key, value) in
//      URLQueryItem(name: key, value: value)
//    })
//    return components
//  }
  
  var requestData: Data? {
    try? JSONSerialization.data(withJSONObject: components, options: .fragmentsAllowed)
  }
  
  
  var method: Method {
    switch self {
    case .token, .users, .files:
      return .post
    }
  }
  
  func setRequest() -> URLRequest? {
    guard let url = URL(string: configuredURL) else { return nil }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    guard let tokenResponse = KeychainSwift()
            .getData(DropboxAPI.tokenKey) else { return nil }
    guard let token = try? JSONDecoder()
            .decode(AuthViewController.TokenResponse.self,
                    from: tokenResponse) else { return nil }
    
    switch self {
    case .token:
      request.setValue("Basic \("\(TokenCredentials.clientID):\(TokenCredentials.clientSecret)".toBase64())",
                       forHTTPHeaderField: "Authorization")
      request.setValue("application/x-www-form-urlencoded",
                       forHTTPHeaderField: "Content-Type")
//       For PCKE extension
      //      URLQueryItem(name: "client_id", value: AuthViewController.Const.clientID),
      //      URLQueryItem(name: "code_verifier", value: code)
    case .users:
      request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
    case .files:
      request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json",
                       forHTTPHeaderField: "Content-Type")
    }
    request.timeoutInterval = 30
//    request.httpBody = requestComponents.query?.data(using: .utf8)
    request.httpBody = requestData
    return request
  }


}
