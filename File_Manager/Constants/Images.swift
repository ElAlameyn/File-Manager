//
//  Images.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import Foundation
import UIKit

struct Images {
  
  // MARK: - Recent Images
  
  static var recentImage1: UIImage? {
    UIImage(named: "recent_image1")
  }
  
  static var recentImage2: UIImage? {
    UIImage(named: "recent_image2")
  }
  
  static var recentImage3: UIImage? {
    UIImage(named: "recent_image3")
  }
  
  static var recentImage4: UIImage? {
    UIImage(named: "recent_image4")
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
