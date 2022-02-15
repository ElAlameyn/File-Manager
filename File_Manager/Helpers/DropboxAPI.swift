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

  func fetchUsageSpace() -> AnyPublisher<UsageSpaceResponse, Error> {
//    let publisher: AnyPublisher<UsageSpaceResponse, Error> =
    
    return getPublisher(request: URLRequest(url: URL(string: "")!))
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
  
  private func createRequestWithToken(url: URL?, method: String) -> URLRequest? {
//    let config = ResponseConfig.users(.usageSpace)
//    guard let url = URL(string: config.configuredURL) else { return }
//    var request = URLRequest(url: url)
//    request.httpMethod = config.method.rawValue
//    config.setHeaders(for: &request)
//    return request
    return nil
  }
}
