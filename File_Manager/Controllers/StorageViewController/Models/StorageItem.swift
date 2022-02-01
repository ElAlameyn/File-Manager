//
//  StorageItem.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

enum StorageItem: Hashable {
  case statistics(Statistic?)
  case lastModified(LastModifiedItem?)
}

extension StorageItem {
  
  static let allModifiedItems: [StorageItem] = [
    .lastModified(LastModifiedItem(title: "image.png", image: Images.categoryImages)),
    .lastModified(LastModifiedItem(title: "Just super big image name to show how cell fit content (okey or not).txt", image: Images.categoryFiles)),
    .lastModified(LastModifiedItem(title: "video.mkv", image: Images.categoryVideos)),
  ]
  
  static let statistic: StorageItem = .statistics(Statistic(usedMemory: 25, totalMemory: 150))
  
}






