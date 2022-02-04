//
//  TabBarViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 02.02.2022.
//

import UIKit
import RxSwift

class TabBarViewController: UITabBarController {

  private let customBar = CustomTabBar()
  private let disposeBag = DisposeBag()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      setUpUI()
      bind()
      view.layoutIfNeeded()
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  private func setUpUI() {
    tabBar.isHidden = true
    
    view.addSubview(customBar)
    customBar.translatesAutoresizingMaskIntoConstraints = false
//    customBar.addEdgeContstraints(exclude: .top, offset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    NSLayoutConstraint.activate([
      customBar.leftAnchor.constraint(equalTo: view.leftAnchor),
      customBar.rightAnchor.constraint(equalTo: view.rightAnchor),
      customBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      customBar.heightAnchor.constraint(equalToConstant: 80)
    ])

    let controllers = CustomTabItem.allCases.map({ $0.viewController })
    setViewControllers(controllers, animated: true)
  }

  private func selectTabWith(index: Int) {
      self.selectedIndex = index
  }
  
  private func bind() {
      customBar.itemTapped
          .bind { [weak self] in self?.selectTabWith(index: $0) }
          .disposed(by: disposeBag)
  }
}
