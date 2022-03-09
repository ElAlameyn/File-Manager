//
//  FoldersListViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.02.2022.
//

import Foundation
import Combine
import UniformTypeIdentifiers

final class FilesViewModel: ObservableObject, ViewModelProtocol {
  @Published private(set) var value: ListFoldersResponse? {
    didSet {
      update?()
    }
  }
  var update: (() -> Void)?
  var subscriber: AnyCancellable?
  
  var images: [ListFoldersResponse.File] {
    return files.compactMap {
      if let fileExtension = NSURL(fileURLWithPath: $0.name).pathExtension {
        guard let uti = UTType(filenameExtension: fileExtension) else { return nil }
        if uti.conforms(to: .image) {
          print("Image!!!!!!!")
          return $0
        }
    }
      return nil
    }
  }
  
  var files: [ListFoldersResponse.File] {
    guard let value = value else { return [] }
    return value.entries.filter({ $0.tag == "file" })
  }
  
  func fetch() {
    subscriber = DropboxAPI.shared.fetchAllFiles()?
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished: print("Finished list all folders request")
        case .failure(let error): print("Failed list all folders request due to: \(error)")
        }
      }, receiveValue: { responce in
        self.value = responce
      })
  }
  
  func countFilesAmount() -> (images: Int, videos: Int, files: Int) {
    var images = 0
    var videos = 0
    var files = 0
    self.files.forEach {
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
}

