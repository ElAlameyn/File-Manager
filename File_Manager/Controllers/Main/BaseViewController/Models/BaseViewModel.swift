//
//  BaseViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 23.04.2023.
//

import Foundation
import Combine


protocol AuthHandlerProtocol {
  func fetch()
}

extension AuthHandlerProtocol {
  func fetch() {}
}

class ViewModel: AuthHandlerProtocol {
  var apiClient = DropboxAPI()
  var authFailHandler = PassthroughSubject<Void, Never>()
  var cancellables = Set<AnyCancellable>()

  init() {
    authFailHandler.sink { [weak self] in
      self?.fetch()
    }.store(in: &cancellables)
  }

  func fetch() {}
}

final class BaseViewModel: FilesModel {

  var currentAccountSubject = CurrentValueSubject<CurrentAccountResponse?, APIError>(nil)

  override func fetch()  {

    apiClient.fetchAllFiles()?
      .sink(
        logInfo: "Fetch Files",
        receiveValue: filesSubject.send,
        errorHandlingSubject: authFailHandler
      )
      .store(in: &cancellables)

   apiClient.fetchCurrentAccount()?
      .sink(
        logInfo: "Fetch Account",
        receiveValue: currentAccountSubject.send,
        errorHandlingSubject: authFailHandler
      )
      .store(in: &cancellables)
  }


}
