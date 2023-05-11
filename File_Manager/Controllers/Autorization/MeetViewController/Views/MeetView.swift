//
//  MeetView.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import UIKit

class MeetView: UIView {
  
  var buttonHandler: (() -> (Void))?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .white
    self.layer.cornerRadius = 57
    setUpUI()
    setUpLayout()
  }
  
  private var titleLabel = UILabel.withStyle(Style.label.blueLargeTitle)
  private var descriptionLabel = UILabel.withStyle(Style.label.desriptionGray)
  private var submitButton = UIButton.withStyle(Style.button.blueButton)

  private func setUpUI() {
    self.addSubview(titleLabel)
    self.addSubview(descriptionLabel)
    self.addSubview(submitButton)
  }

  private func setUpLayout() {
    titleLabel.addEdgeContstraints(exclude: .bottom, offset: UIEdgeInsets(top: 35, left: 22, bottom: 0, right: -22))
    
    descriptionLabel.addEdgeContstraints(exclude: .bottom, .top, offset: UIEdgeInsets(top: 35, left: 22, bottom: 0, right: -22))
    descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
    descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    submitButton.addEdgeContstraints(exclude: .top, offset: UIEdgeInsets(top: 0, left: 30, bottom: -25, right: -30))
    submitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    submitButton.addTarget(nil, action: #selector(MeetViewController.submitButtonTapped), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
