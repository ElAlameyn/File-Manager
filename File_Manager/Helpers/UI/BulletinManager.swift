//
//  BulletinManager.swift
//  File_Manager
//
//  Created by Артем Калинкин on 03.04.2022.
//

import Foundation
import BLTNBoard
import UIKit

#warning("Customize appearance")
final class BulletinManager {
  
  lazy var textFieldItem = makeTextFieldPage()
  private lazy var manager = BLTNItemManager(rootItem: textFieldItem)

  func makeTextFieldPage() -> TextFieldBulletinPage {
    let page = TextFieldBulletinPage(title: Texts.bulletinTitle)
    page.appearance.titleFontSize = 24
    page.isDismissable = true
    page.descriptionText = nil
    page.actionButtonTitle = Texts.bulletinTextFieldTitle
    return page
  }
  
  func dismiss() {
    manager.dismissBulletin(animated: true)
  }
  
  func presentOn(viewController: UIViewController) {
    manager.showBulletin(above: viewController)
  }
  
  
}
