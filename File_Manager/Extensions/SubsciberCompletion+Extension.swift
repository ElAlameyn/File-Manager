//
//  SubsciberCompletion+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.04.2022.
//

import Combine

extension Subscribers.Completion {
  func debugCompletion(descr: String, subject: PassthroughSubject<Void, Never>) {
    switch self {
    case .finished: print("[API SUCCESSFUL] - \(descr)")
    case .failure(let error):
      print("[API FAILED] - \(descr) due to \(error)")
      if error.getExpiredTokenStatus() {
        subject.send()
      }
    }
  }
}
