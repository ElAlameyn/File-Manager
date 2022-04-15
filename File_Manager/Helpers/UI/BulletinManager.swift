//
//  BulletinManager.swift
//  File_Manager
//
//  Created by Артем Калинкин on 03.04.2022.
//

import BLTNBoard
import UIKit
import Combine

#warning("Customize appearance")
final class BulletinManager {
  
  private var textFieldItem: TextFieldBulletinPage!
  private lazy var manager = BLTNItemManager(rootItem: textFieldItem)
  
  init(title: String, actionButton: String? = "Rename") {
    textFieldItem = TextFieldBulletinPage(title: title)
    textFieldItem.appearance.titleFontSize = 24
    textFieldItem.isDismissable = true
    textFieldItem.descriptionText = nil
    textFieldItem.actionButtonTitle = Texts.bulletinTextFieldTitle
  }
  


  func dismissing() {
    manager.dismissBulletin(animated: true)
  }
  
  func presentOn(viewController: UIViewController) {
    manager.showBulletin(above: viewController)
  }
  
}
