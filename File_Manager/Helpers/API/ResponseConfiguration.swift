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
  case fileRequestList(limit: Int)

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
      case .fileRequestList: return baseURL + "/2/file_requests" + "/list_v2"
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
      case .fileRequestList(limit: let limit):
        return ["limit": limit]
    }
  }
  
  private var requestComponents: URLComponents {
    var components = URLComponents()
    components.queryItems = self.components?.compactMap({ (key, value) in
      (value as? String).map { URLQueryItem(name: key, value: $0)}
    })
    return components
  }
  
  private var jsonData: Data? {
    try? JSONSerialization.data(withJSONObject: components as Any, options: .fragmentsAllowed)
  }
  
  func setRequest() -> URLRequest? {
    guard let url = URL(string: configuredURL) else { return nil }
    var request = URLRequest(url: url)
    request.httpMethod = .post
    
    let token = KeychainSwift().getData(DropboxAPI.tokenKey)
      .flatMap { try? JSONDecoder().decode(TokenResponse.self, from: $0) }
      .map(\.accessToken) ?? ""

    switch self {
      case .token: break
      default: request.set(token: token)
    }

    switch self {
      case .token: request.set(contentType: .application_x_www_form_urlencoded)
      case .listFolder, .search, .deleteFile, .createFolder, .check:
        request.set(contentType: .application_json)
      case .createPaper, .upload: request.set(contentType: .application_octet_stream)

      default: break
    }
    
    switch self {
      case .token:
        request.setValue(
          "Basic \("\(TokenCredentials.clientID):\(TokenCredentials.clientSecret)".toBase64())",
          forHTTPHeaderField: "Authorization"
        )
        request.httpBody = requestComponents.query?.data(using: .utf8)
      case .users: break
      case .thumbnail(let path):
        request.setDropboxAPIArg(path)
      case .download(let id):
        request.setDropboxAPIArg(id)
      case .check: break
      case .listFolder, .search, .deleteFile, .createFolder, .fileRequestList:
        request.httpBody = jsonData
      case .createPaper(fullPath: let fullPath):
        request.setDropboxAPIArg(fullPath)
      case .upload(fileData: let fileData, path: let path):
        request.setDropboxAPIArg(path)
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
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash).replaceHash()
  }
  
}

