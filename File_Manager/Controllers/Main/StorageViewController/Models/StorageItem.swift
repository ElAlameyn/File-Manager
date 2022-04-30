//
//  StorageItem.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

enum StorageItem: Hashable {
  case usageSpace(UsageSpaceResponse?)
  case uploadButton
  case recentlyUploaded(ListFoldersResponse.File)
}





