//
//  UIViewController+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 23.04.2023.
//

import UIKit

extension UIViewController {
  func handleAuth(comletion: @escaping () -> Void) {
    let authVC = AuthViewController()
    authVC.modalPresentationStyle = .fullScreen
    self.present(authVC, animated: true)
    authVC.dismissed = {
      authVC.dismiss(animated: true)
      comletion()
    }
  }
}

