//
//  UIImageView+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 23.02.2022.
//

import UIKit
import UniformTypeIdentifiers

extension UIImageView {
  

  func setCategoryFor(name: String? = nil) {
    guard let name = name else { return }
    switch name {
    case "Images":
      self.image = Images.categoryImages
    case "Videos":
      self.image = Images.categoryVideos
    case "Files":
      self.image = Images.categoryFiles
    default: return
    }
  }
  
  func setCategoryFor(file: String? = nil) {
    guard let file = file else { return }
    if let fileExtension = NSURL(fileURLWithPath: file).pathExtension {
      guard let uti = UTType(filenameExtension: fileExtension) else { return }
      if uti.conforms(to: .image) {
        self.image = Images.categoryImages
      } else if uti.conforms(to: .video) {
        self.image = Images.categoryVideos
      } else if uti.conforms(to: .item) {
        self.image = Images.categoryFiles
      }
    }
  }
}

