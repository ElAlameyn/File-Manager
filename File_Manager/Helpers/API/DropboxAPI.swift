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

  func fetchUsageSpace() -> AnyPublisher<UsageSpaceResponse, Error>? {
    guard let request = RequestConfigurator.users(.usageSpace).setRequest() else { return nil }
    return getPublisher(request: request)
  }
  
  func fetchAllFiles() -> AnyPublisher<ListFoldersResponse, Error>? {
    guard let request = RequestConfigurator.files(.listAllFolders).setRequest() else { return nil }
    return getPublisher(request: request)
  }
  
  func fetchDownload(id: String? = nil) -> AnyPublisher<Data, Error>? {
    guard let id = id else { return nil }
    guard let request = RequestConfigurator.download(
    """
      {"path":"\(id)"}
    """
    ).setRequest() else { return nil }
    return getDataPublisher(request: request)
  }

  func fetchThumbnail(path: String? = nil) -> AnyPublisher<Data, Error>? {
    guard let path = path else { return nil }
    print("PATH: \(path)")
    guard let request = RequestConfigurator.thumbnail(
    """
      {"path":"\(path)", "format":"jpeg"}
    """
    ).setRequest() else { return nil }
    print("REQUEST THUMBNAIL: \(request.url?.absoluteString as Any)")
    return getDataPublisher(request: request)
  }
  
  // MARK: - Private
  
  private func getPublisher<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
    URLSession.shared.dataTaskPublisher(for: request)
      .subscribe(on: DispatchQueue.global())
      .map ({ $0.data })
    // temporary for debugging
      .map({ value in
        let object = try? Data(value)
        if let image = UIImage(data: value) {
          print("Archived image: \(image)")
        }
//        let object = try? JSONSerialization.jsonObject(with: value, options: .fragmentsAllowed)
        print("Object: \(object)")
        return value
      })
      .decode(type: T.self,
              decoder: JSONDecoder())
//      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
  
  private func getDataPublisher(request: URLRequest) -> AnyPublisher<Data, Error> {
    URLSession.shared.dataTaskPublisher(for: request)
      .subscribe(on: DispatchQueue.global())
      .map ({ $0.data })
      .tryMap({ Data($0) })
      .map({
        print("DATA IMAGE: \($0)")
        if let _ = UIImage(data: $0) {
          print("Archived")
        }
        return $0
      })
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}
