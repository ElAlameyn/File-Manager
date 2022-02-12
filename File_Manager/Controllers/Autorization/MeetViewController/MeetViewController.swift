//
//  ViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit

class MeetViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
  }
  
  private func setUpUI() {
    view.backgroundColor = Colors.meetBlueBackground
    addBlueLock()
    addMeetView()
  }
  
  private func addMeetView() {
    let meetView = MeetView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 300)))
    
    view.addSubview(meetView)
    
    meetView.addCenterConstraints(exclude: .axisY)
    meetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -92).isActive = true
    meetView.addHeightWeightConstraints(values: CGPoint(x: 300, y: 300))
    
    meetView.buttonHandler = {
      let baseVC = AuthViewController()
      self.navigationController?.pushViewController(baseVC, animated: true)
    }
  }

  private func addBlueLock() {
    let imageView = UIImageView(image: Images.blueLock)
    view.addSubview(imageView)
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.addCenterConstraints()
    imageView.addHeightWeightConstraints(values: CGPoint(x: 800, y: 800))
  }
}


