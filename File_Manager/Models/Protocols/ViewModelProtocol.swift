//
//  ViewModelProtocol.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.02.2022.
//

import Combine
import Foundation

protocol BaseProtocol: AnyObject{}

protocol ViewModelProtocol: BaseProtocol {
  associatedtype T: Hashable, Decodable
  var value: T { get set }
  var cancellables: Set<AnyCancellable> { get set }
  var failedRequest: (() -> Void)? { get set }
}

extension ViewModelProtocol {
  
  /// Fetching for responses
  func fetch(f: () -> AnyPublisher<T, Error>?) {
    f()?
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          print("[FETCH RESULT]: \(T.self) response succeded" )
        case .failure(let error):
          print("[FETCH RESULT]: \(T.self) response failed due to \(error)")
          self.failedRequest?()
        }
      }, receiveValue: { value in
        self.value = value
      })
      .store(in: &cancellables)
  }
  
  /// Fetching for data
  func fetch(f: AnyPublisher<T, Error>?) {
    f?
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          print("[FETCH RESULT]: \(T.self) response succeded" )
        case .failure(let error):
          print("[FETCH RESULT]: \(T.self) response failed due to \(error)")
          self.failedRequest?()
        }
      }, receiveValue: { value in
        self.value = value
      })
      .store(in: &cancellables)
  }
}



