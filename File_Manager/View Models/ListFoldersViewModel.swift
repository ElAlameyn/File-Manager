//
//  FoldersListViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.02.2022.
//

import Foundation
import Combine

final class ListFoldersViewModel: ObservableObject, ViewModelProtocol {
  @Published private(set) var value: ListFoldersResponse?
  var subscriber: AnyCancellable?
  
  func fetch(with filterType: FilterType? = nil) {
    subscriber = DropboxAPI.shared.fetchAllFiles()?
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          print("Finished list all folders request")
        case .failure(let error):
          print("Failed list all folders request due to: \(error)")
        }
      }, receiveValue: { responce in
        self.value = responce
        switch filterType {
        case .modified:
          break
        case .byName: self.value?.entries.sort(by: {$0.name < $1.name })
        case .starred:
          break
        case .none:
          break
        }
      })
  }

}

extension ListFoldersViewModel {
  enum FilterType {
    case modified, byName, starred
  }
}
