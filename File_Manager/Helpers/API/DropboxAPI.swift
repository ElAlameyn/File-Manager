//
//  DropboxAPI.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.02.2022.
//

import Foundation
import Combine

final class DropboxAPI {
  
  static let shared = DropboxAPI()
  static let tokenKey = "token_key"

  func fetchUsageSpace() -> AnyPublisher<UsageSpaceResponse, Error>? {
    guard let request = RequestConfigurator.users(.usageSpace).setRequest() else { return nil }
    return getPublisher(request: request)
  }
  
  // MARK: - Private
  
  private func getPublisher<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
    URLSession.shared.dataTaskPublisher(for: request)
      .subscribe(on: DispatchQueue.global())
      .map ({ $0.data })
      .decode(type: T.self,
              decoder: JSONDecoder())
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}
