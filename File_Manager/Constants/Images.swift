//
//  Images.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import Foundation
import UIKit

struct Images
{
  
  // MARK: - Header View Images
  
  static var addFileImage: UIImage? {
    UIImage(named: "add_file")
  }
  
  static var addFolderImage: UIImage? {
    UIImage(named: "add_folder")
  }

  // MARK: - Recent Images
  
  static var rightBottomImage: UIImage? {
    UIImage(named: "right_bottom_image")
  }
  
  static var leftUpperImage: UIImage? {
    UIImage(named: "left_upper_image")
  }
  
  // MARK: - Category Images
  
  static var categoryImages: UIImage? {
    UIImage(named: "images_category")
  }
  
  static var categoryFiles: UIImage? {
    UIImage(named: "files_category")
  }
  
  static var categoryVideos: UIImage? {
    UIImage(named: "video_category")
  }
  
  static var categoryFolder: UIImage? {
    UIImage(named: "folder_category")?
      .withTintColor(UIColor(red: 48 / 255, green: 48 / 255, blue: 48 / 255, alpha: 1))
  }
  
  
  // MARK: - Meet Screen Image
  
  static var blueLock: UIImage? {
    UIImage(named: "blue_lock")
  }
  
  // MARK: - Navigation Bar
  
  static var baseLeftItem: UIImage? {
    UIImage(named: "baseLeftItem")
  }
  
  static var baseRightItem: UIImage? {
    UIImage(named: "baseRightItem")
  }
}
