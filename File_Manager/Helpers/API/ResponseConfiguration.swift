//
//  ResponseType.swift
//  File_Manager
//
//  Created by Артем Калинкин on 14.02.2022.
//

import Foundation
import KeychainSwift
import CommonCrypto

enum RequestConfigurator {
  
  static let codeVerifierKey = "code_verifier_key"
  
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
  case listFolder(path: String, recursive: Bool)
  case thumbnail(String)
  case download(String)
  case check
  case search(query: String)
  
  var baseURL: String { "https://api.dropboxapi.com" }
  var contentURL: String { "https://content.dropboxapi.com" }
  
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
    case .listFolder:
      let startPoint = baseURL + "/2/files"
      return startPoint + "/list_folder"
    case .thumbnail(_):
      let startPoint = contentURL + "/2/files"
      return startPoint + "/get_thumbnail"
    case .download(_):
      let startPoint = contentURL + "/2/files"
      return startPoint + "/download"
    case .check:
      let startPoint = baseURL + "/2/check"
      return startPoint + "/user"
    case .search:
      let startPoint = baseURL + "/2/files"
      return startPoint + "/search_v2"
    }
  }
  
  private var components: [String: Any]? {
    switch self {
    case .token(let code):
      print("USED CODE VERIFIER: \(KeychainSwift().get(RequestConfigurator.codeVerifierKey) ?? "")")
      return ["grant_type": "authorization_code",
              "code": code,
              "redirect_uri": TokenCredentials.redirectURI,
              //              "client_id": TokenCredentials.clientID,
              "code_verifier": KeychainSwift().get(RequestConfigurator.codeVerifierKey) ?? ""
      ]
    case .users: return nil
    case .listFolder(let path, let recursive):
      return ["path": path,
              "recursive": recursive,
              "limit": 10 ]
    case .thumbnail(let path):
      return [ "path": path,
               "format": "jpeg",
               "size": "w64h64",
               "mode": "strict" ]
    case .download(let id):
      return ["path": id]
    case .check:
      return ["query": "foo"]
    case .search(query: let query):
      return ["query": query]
    }
  }
  
  private var requestComponents: URLComponents {
    var components = URLComponents()
    components.queryItems = self.components?.compactMap({ (key, value) in
      guard let string = value as? String else { return nil }
      return URLQueryItem(name: key, value: string)
    })
    return components
  }
  
  private var jsonData: Data? {
    try? JSONSerialization.data(withJSONObject: components as Any, options: .fragmentsAllowed)
  }
  
  func setRequest() -> URLRequest? {
    guard let url = URL(string: configuredURL) else { return nil }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    var token = ""
    
    if let tokenResponse = KeychainSwift()
      .getData(DropboxAPI.tokenKey),
       let get = try? JSONDecoder()
      .decode(AuthViewController.TokenResponse.self,
              from: tokenResponse) {
      token = get.accessToken
    }
    
    switch self {
    case .token:
      request.setValue("Basic \("\(TokenCredentials.clientID):\(TokenCredentials.clientSecret)".toBase64())",
                       forHTTPHeaderField: "Authorization")
      request.setValue("application/x-www-form-urlencoded",
                       forHTTPHeaderField: "Content-Type")
      
      request.httpBody = requestComponents.query?.data(using: .utf8)
    case .users:
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    case .listFolder:
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = jsonData
    case .thumbnail(let path):
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue(path, forHTTPHeaderField: "Dropbox-API-Arg")
    case .download(let id):
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue(id, forHTTPHeaderField: "Dropbox-API-Arg")
    case .check:
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    case .search:
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = jsonData
    }
    request.timeoutInterval = 60
    return request
  }
}

// MARK: - PCKE extension
extension RequestConfigurator {
  
  static func createCodeVerifier() -> String {
    var buffer = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
    return Data(buffer).replaceHash()
  }
  
  static func createCodeChallenge(for verifier: String) -> String {
    guard let data = verifier.data(using: .utf8) else { fatalError() }
    var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { _ = CC_SHA256($0, CC_LONG(data.count), &buffer) }
    return Data(buffer).replaceHash()
  }
  
}

