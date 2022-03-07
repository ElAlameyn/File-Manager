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
  
  @Published private(set) var images: [UIImage]?
  var subscriber: AnyCancellable?

  func fetch(path: String? = nil) {
    subscriber = DropboxAPI.shared.fetchDownload(id: path)?.sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        print("Fetched thmbnail succesful")
      case .failure(let error):
        print("Fetch thmbnail failed due to \(error)")
      }
    }, receiveValue: { [weak self] data in
      guard let self = self else { return }
      if let image = UIImage(data: data ) {
        guard var images = self.images else { return }
        if images.filter { $0 == image }.isEmpty {
          self.images?.append(image)
          self.update?()
        }
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
