//
//  ThumbnailViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 25.02.2022.
//

import UIKit
import Combine

final class ImagesLoader: ObservableObject {
  var cancellables = Set<AnyCancellable>()
  
  func fetch(path: String? = nil, completion: @escaping (UIImage) -> Void) {
    DropboxAPI.shared.fetchDownload(id: path)?.sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        print("Fetched thmbnail succesful")
      case .failure(let error):
        print("Fetch thmbnail failed due to \(error)")
      }
    }, receiveValue: { data in
      if let image = UIImage(data: data ) {
        completion(image)
      }
    })
      .store(in: &cancellables)
  }
}

