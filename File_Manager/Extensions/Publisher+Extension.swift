//
//  Publisher+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 23.04.2023.
//

import Combine

public extension Publisher {
  func sink(
    logInfo: String? = "",
    receiveValue: @escaping ((Self.Output) -> Void),
    errorHandlingSubject: PassthroughSubject<Void, Never>? = nil
  ) -> AnyCancellable {
    self.sink(receiveCompletion: {
      switch $0 {
        case .finished:
          _ = print("[API SUCCESSFUL] - \(logInfo)")
        case let .failure(error):
          _ = print("[API FAIL] - \(logInfo): \(error.localizedDescription)")
          if error.getExpiredTokenStatus() { errorHandlingSubject?.send() }
      }
    }, receiveValue: receiveValue)
  }

  func sink(for subject: CurrentValueSubject<Self.Output, Self.Failure>) -> AnyCancellable {
    self.sink(receiveCompletion: subject.send(completion:), receiveValue: subject.send(_:))
  }
}
