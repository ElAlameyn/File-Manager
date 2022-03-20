//
//  ViewModelProtocol.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.02.2022.
//

import Combine
import Foundation
import UIKit

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
  
  /// Run Authorization after expiring token
  func handleFail(on viewController: UIViewController,
                  completionHandler: @escaping Empty) {
    DispatchQueue.main.async {
      let authVC = AuthViewController()
      authVC.modalPresentationStyle = .fullScreen
      viewController.navigationController?.present(authVC, animated: true)
      authVC.dismissed = {
        authVC.dismiss(animated: true) {
          completionHandler()
        }
      }
    }
  }
}



