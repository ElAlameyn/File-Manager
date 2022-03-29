//
//  ViewModelProtocol.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.02.2022.
//

import Combine
import Foundation
import UIKit

protocol BaseProtocol: AnyObject{}

protocol ViewModelProtocol: BaseProtocol {
  var cancellables: Set<AnyCancellable> { get set }
}

extension ViewModelProtocol {

  /// Run Authorization after expiring token
  func handleFail(on viewController: UIViewController,
                  completionHandler: @escaping Empty) {
    DispatchQueue.main.async {
      let authVC = AuthViewController()
      authVC.modalPresentationStyle = .fullScreen
      viewController.navigationController?.present(authVC, animated: true)
      authVC.dismissed = {
        authVC.dismiss(animated: true) {
          completionHandler()
        }
      }
    }
  }
}



