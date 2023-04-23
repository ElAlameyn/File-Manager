//
//  Publisher+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 23.04.2023.
//

import Combine

extension Publisher {
  public func sink(
    logInfo: String? = "",
    receiveValue: @escaping ((Self.Output) -> Void),
    errorHandlingSubject: PassthroughSubject<Void, Never>? = nil
  ) -> AnyCancellable {
    self.sink(receiveCompletion: {
      switch $0 {
        case .finished:
          _ = print("[API SUCCESSFUL] - \(logInfo)")
        case .failure(let error):
          _ = print("[API FAIL] - \(logInfo): \(error.localizedDescription)")
          if error.getExpiredTokenStatus() { errorHandlingSubject?.send() }
      }
    }, receiveValue: receiveValue)
  }
}
