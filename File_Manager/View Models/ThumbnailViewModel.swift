//
//  ThumbnailViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 25.02.2022.
//

import UIKit
import Combine

final class ThumbnailViewModel: ObservableObject {
  
  var update: (() -> Void)?
  
  private let id = UUID()
  
  @Published private(set) var image: UIImage?
  var subscriber: AnyCancellable?

  func fetch(path: String? = nil) {
    subscriber = DropboxAPI.shared.fetchThumbnail(path: path)?.sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        print("Fetched thmbnail succesful")
      case .failure(let error):
        print("Fetch thmbnail failed due to \(error)")
      }
    }, receiveValue: { data in
      if let image = UIImage(data: data ) {
        self.image = image
        self.update?()
        print("Successful thumbnail unarchived")
      }
    })
  }
}

extension ThumbnailViewModel: Hashable {
  static func == (lhs: ThumbnailViewModel, rhs: ThumbnailViewModel) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
}
