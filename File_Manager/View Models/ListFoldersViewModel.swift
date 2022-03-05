//
//  FoldersListViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.02.2022.
//

import Foundation
import Combine
import UniformTypeIdentifiers

final class ListFoldersViewModel: ObservableObject, ViewModelProtocol {
  @Published private(set) var value: ListFoldersResponse?
  var subscriber: AnyCancellable?
  
  func fetch() {
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
      })
  }
  
  func countFilesAmount(value: ListFoldersResponse?) -> (images: Int, videos: Int, files: Int) {
    var images = 0
    var videos = 0
    var files = 0
    value?.files.forEach {
      if let fileExtension = NSURL(fileURLWithPath: $0.name).pathExtension {
        guard let uti = UTType(filenameExtension: fileExtension) else { return }
        if uti.conforms(to: .image) {
          images += 1
        } else if uti.conforms(to: .video) {
          videos += 1
        } else if uti.conforms(to: .item) {
          files += 1
        }
      }
    }
    return (images, videos, files)
  }
  
  func images(_ value: ListFoldersResponse?) -> [ListFoldersResponse.File]? {
    guard let value = value else { return nil }
    var result = [ListFoldersResponse.File]()
    
    for file in value.files {
      if let fileExtension = NSURL(fileURLWithPath: file.name).pathExtension {
        guard let uti = UTType(filenameExtension: fileExtension) else { break }
        if uti.conforms(to: .image) {
          result.append(file)
        }
      }
    }

    return result
  }
}

