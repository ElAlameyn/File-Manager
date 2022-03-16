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
  
  var update: ((UIImage) -> Void?)?
  
  var value: Data? {
    didSet {
      if let value = value, let image = UIImage(data: value) {
        update?(image)
      }
    }
  }
  

}

