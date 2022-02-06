//
//  StatisticViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 05.02.2022.
//

import UIKit

class StatisticViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = .white
    title = "Statistic"
  }
}
