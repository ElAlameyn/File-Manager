//
//  BaseViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    
    setUpUI()
  }
  
  private func setUpUI() {
    addLeftBarButtonItem()
    addRightBarButtonItem()
  }
  
  private func addLeftBarButtonItem() {
    let button = UIButton(type: .custom)
    button.setImage(Images.baseLeftItem, for: .normal)
    button.sizeToFit()

    button.addTarget(self, action: #selector(leftBarButtonItemTapped), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
  }

  private func addRightBarButtonItem() {
    let button = UIButton(type: .custom)
    button.setImage(Images.baseRightItem, for: .normal)
    button.sizeToFit()

    button.addTarget(self, action: #selector(rightBarButtonItemTapped), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
  }
  
  @objc func leftBarButtonItemTapped() {
    print("Left button tapped")
  }
  
  @objc func rightBarButtonItemTapped() {
    print("Left button tapped")
  }
  
}
