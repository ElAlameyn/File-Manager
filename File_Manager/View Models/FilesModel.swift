//
//  FoldersListViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.02.2022.
//

import Foundation
import Combine
import UniformTypeIdentifiers

class FilesModel: ViewModel, ObservableObject, ViewModelProtocol {

  var update: (() -> Void)?

  var filesSubject = CurrentValueSubject<ListFoldersResponse?, APIError>(nil)
  
  var value: ListFoldersResponse? {
    filesSubject.value
  }
  
  var files: [ListFoldersResponse.File] {
    guard let value = value else { return [] }
    return value.entries.filter({ $0.tag == "file" })
  }
  
  var allFiles: [ListFoldersResponse.File] {
    guard let value = value else { return [] }
    return value.entries
  }
  
  var images: [ListFoldersResponse.File] {
    files.compactMap {
      if let fileExtension = NSURL(fileURLWithPath: $0.name).pathExtension {
        guard let uti = UTType(filenameExtension: fileExtension) else { return nil }
        if uti.conforms(to: .image) { return $0 }
    }
      return nil
    }
  }
  
  func countFilesAmount() -> (images: Int, videos: Int, files: Int) {
    var images = 0
    var videos = 0
    var files = 0
    self.files.forEach {
      if let fileExtension = NSURL(fileURLWithPath: $0.name).pathExtension {
        guard let uti = UTType(filenameExtension: fileExtension) else { return }
        switch uti {
        case _ where uti.conforms(to: .image): images += 1
        case _ where uti.conforms(to: .video): videos += 1
        case _ where uti.conforms(to: .item): files += 1
        default: break
        }
      }
    }
    return (images, videos, files)
  }
  
  func filteredByDateModified(inverse: Bool? = false) -> [ListFoldersResponse.File] {
    var filtered = files
    let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    if !(inverse!) {
      filtered.sort {
        if let date1 = $0.clientModified?.toDate(dateFormat: dateFormat),
           let date2 = $1.clientModified?.toDate(dateFormat: dateFormat) {
          return date1 > date2
        }
        return false
      }
    } else {
      filtered.sort {
        if let date1 = $0.clientModified?.toDate(dateFormat: dateFormat),
           let date2 = $1.clientModified?.toDate(dateFormat: dateFormat) {
          return date1 < date2
        }
        return false
      }
    }
    return filtered
  }

}

