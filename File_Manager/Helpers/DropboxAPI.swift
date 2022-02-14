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
}
