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
