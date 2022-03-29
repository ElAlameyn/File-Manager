//
//  ThumbnailViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 25.02.2022.
//

import UIKit
import Combine

final class ImageViewModel: ObservableObject, ViewModelProtocol {
  var failedRequest: (() -> Void)?
  var cancellables = Set<AnyCancellable>()
  var value = CurrentValueSubject<Data?, APIError>(nil)
  
  var image: UIImage? {
    var image: UIImage?
    value.sink(receiveCompletion: {_ in}) {
      if let data = $0 { image = UIImage(data: data) }
    }.store(in: &cancellables)
    return image
  }
}

