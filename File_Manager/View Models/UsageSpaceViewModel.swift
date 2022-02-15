//
//  UsageSpaceViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.02.2022.
//

import Foundation
import Combine


final class UsageSpaceViewModel: ObservableObject, ViewModelProtocol {
  @Published private(set) var usageSpace: UsageSpaceResponse?
  var subscriber: AnyCancellable?
  
  func fetch() {
    subscriber = DropboxAPI.shared.fetchUsageSpace()?.sink(
      receiveCompletion: { completion in
        switch completion {
        case .finished:
          print("Usage space respnose received")
        case .failure(let error):
          print("Usage space respnose failed due to: \(error)")
        }
      }, receiveValue: { response in
        self.usageSpace = response
        print("USAGE SPACE RESPONSE: \(response)")
      })
  }
}
