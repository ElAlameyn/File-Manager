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
    case currentAccount = "/get_current_account"
  }
  
  private struct TokenCredentials {
    static let clientID = "688rvrlb7upz9jb"
    static let clientSecret = "2zb3cvcxd9e7a2s"
    static let redirectURI = "http://localhost"
  }
  
  case token(String)
  case users(Users)
  case listFolder(path: String, recursive: Bool)
  case thumbnail(fullPath: String)
  case download(fullPath: String)
  case check
  case search(query: String)
  case deleteFile(id: String)
  case createFolder(path: String)
  case createPaper(fullPath: String)
  case upload(fileData: Data, path: String)
  

  var baseURL: String { "https://api.dropboxapi.com" }
  var contentURL: String { "https://content.dropboxapi.com" }
  
  var configuredURL: String {
    switch self {
    case .token: return baseURL + "/oauth2/token"
    case .users(let user): return  baseURL + "/2/users" + user.rawValue
    case .listFolder: return baseURL + "/2/files" + "/list_folder"
    case .thumbnail: return contentURL + "/2/files" + "/get_thumbnail"
    case .download: return contentURL + "/2/files" + "/download"
    case .check: return baseURL + "/2/check" + "/user"
    case .search: return baseURL + "/2/files" + "/search_v2"
    case .deleteFile: return baseURL + "/2/files" + "/delete_v2"
    case .createFolder: return baseURL + "/2/files" + "/create_folder_v2"
    case .createPaper: return baseURL + "/2/files" + "/paper/create"
    case .upload: return contentURL + "/2/files" + "/upload"
    }
  }
  
  private var components: [String: Any]? {
    switch self {
    case .token(let code):
      return [
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": TokenCredentials.redirectURI,
        "code_verifier": KeychainSwift().get(RequestConfigurator.codeVerifierKey) ?? ""
      ]
    case .users: return nil
    case .listFolder(let path, let recursive):
      return [
        "path": path,
        "recursive": recursive,
        "limit": 10
      ]
    case .thumbnail(let path):
      return [
        "path": path,
        "format": "jpeg",
        "size": "w64h64",
        "mode": "strict"
      ]
    case .download(let id):
      return ["path": id]
    case .check:
      return ["query": "foo"]
    case .search(query: let query):
      return ["query": query]
    case .deleteFile(id: let id):
      return ["path": id]
    case .createFolder(path: let path):
      return [
        "path": path,
        "autorename": true
      ]
    case .createPaper: return nil
    case .upload: return nil
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
    case .thumbnail(let path):
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue(path, forHTTPHeaderField: "Dropbox-API-Arg")
    case .download(let id):
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue(id, forHTTPHeaderField: "Dropbox-API-Arg")
    case .check:
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    case .listFolder, .search, .deleteFile, .createFolder:
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = jsonData
    case .createPaper(fullPath: let fullPath):
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue(fullPath, forHTTPHeaderField: "Dropbox-API-Arg")
      request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    case .upload(fileData: let fileData, path: let path):
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue(path, forHTTPHeaderField: "Dropbox-API-Arg")
      request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
      request.httpBody = fileData
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

