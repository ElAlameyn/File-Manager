//
//  DropboxAPI.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.02.2022.
//

import Foundation
import Combine
import UIKit

final class DropboxAPI {
  static let shared = DropboxAPI()
  static let tokenKey = "token_key"
  
  func fetchCreateFolder(with name: String, at path: String) -> AnyPublisher<Data?, Error>? {
    let configuredPath = path + "/\(name)"
    guard let request = RequestConfigurator.createFolder(path: configuredPath).setRequest()  else { return nil }
    return getDataPublisher(request: request)
  }
  
  func fetchDeleteFile(at id: String) -> AnyPublisher<Data?, Error>? {
    guard let request = RequestConfigurator.deleteFile(id: id).setRequest() else { return nil }
    return getDataPublisher(request: request)
  }
  
  func fetchCurrentAccount() -> AnyPublisher<CurrentAccountResponse?, Error>? {
    guard let request = RequestConfigurator.users(.currentAccount).setRequest() else { return nil }
    return getPublisher(request: request)
  }
  
  func fetchUsageSpace() -> AnyPublisher<UsageSpaceResponse?, Error>? {
    guard let request = RequestConfigurator.users(.usageSpace).setRequest() else { return nil }
    return getPublisher(request: request)
  }
  
  func fetchAllFiles(path: String = "", recursive: Bool = true) -> AnyPublisher<ListFoldersResponse?, Error>? {
    guard let request = RequestConfigurator.listFolder(path: path, recursive: recursive).setRequest() else { return nil }
    return getPublisher(request: request)
  }
  
  func fetchSearch(q: String = "") -> AnyPublisher<SearchResponse?, Error>? {
    guard let request = RequestConfigurator.search(query: q).setRequest() else { return nil }
    return getPublisher(request: request)
  }
  
  func fetchDownload(id: String? = nil) -> AnyPublisher<Data?, Error>? {
    guard let id = id else { return nil }
    guard let request = RequestConfigurator.download(
    """
      {"path":"\(id)"}
    """
    ).setRequest() else { return nil }
    return getDataPublisher(request: request)
  }
  
  func fetchThumbnail(path: String? = nil) -> AnyPublisher<Data?, Error>? {
    guard let path = path else { return nil }
    guard let request = RequestConfigurator.thumbnail(
    """
      {"path":"\(path)", "format":"jpeg"}
    """
    ).setRequest() else { return nil }
    return getDataPublisher(request: request)
  }
  
  // MARK: - Private
  
  private func getPublisher<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
    URLSession.shared.dataTaskPublisher(for: request)
      .subscribe(on: DispatchQueue.global())
      .tryMap {(data, response) in
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
          throw APIError.statusCode(httpResponse.statusCode)
        }
        #warning("FOR TEST")
        let object = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        print("Object: \(String(describing: object))")
        return data
      }
      .decode(type: T.self,
              decoder: JSONDecoder())
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
  
  private func getDataPublisher(request: URLRequest) ->  AnyPublisher<Data?, Error> {
    URLSession.shared.dataTaskPublisher(for: request)
      .subscribe(on: DispatchQueue.global())
      .tryMap {(data, response) in
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
          throw APIError.statusCode(httpResponse.statusCode)
        }
        #warning("FOR TEST")
        let string = String(data: data, encoding: .utf8)
        print(string)
        print("HTTP CODE", (response as? HTTPURLResponse)?.statusCode )
        let object = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        print("Object: \(object)")
        return data
      }
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}
