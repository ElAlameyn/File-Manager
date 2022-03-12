//
//  DetailImageViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 09.03.2022.
//

import UIKit

class DetailImageController: UIViewController {
  
  private lazy var imageScrollView = ImageScrollView(frame: view.bounds)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    view.addSubview(imageScrollView)
    imageScrollView.addEdgeContstraints()
  }

  func change(image: UIImage?) {
    imageScrollView.set(image: image)
  }
  
}

