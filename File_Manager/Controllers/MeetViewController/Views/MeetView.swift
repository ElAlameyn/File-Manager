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
  }
  
  private var titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMedium,
      color: Colors.labelBlueColor,
      text: Texts.meetTitleLabelText))
  
  private var descriptionLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoRegular,
      color: .systemGray,
      text: Texts.meetDescriptionLabelText)
                                                   )
  private var submitButton = UIButton.withStyle(
    f: Style.rounded(radius: 20) <>
    Style.configureButtonTitle(withTitle: Texts.meetButtonTitle, color: .white)
    <> {
      $0.backgroundColor = Colors.buttonBlueColor
      $0.titleLabel?.font = Fonts.robotoBold
    })


  private func setUpUI() {
    self.addSubview(titleLabel)
    titleLabel.addEdgeContstraints(exclude: .bottom, offset: UIEdgeInsets(top: 35, left: 22, bottom: 0, right: -22))
    
    self.addSubview(descriptionLabel)
    descriptionLabel.addEdgeContstraints(exclude: .bottom, .top, offset: UIEdgeInsets(top: 35, left: 22, bottom: 0, right: -22))
    descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
    
    self.addSubview(submitButton)
    submitButton.addEdgeContstraints(exclude: .top, offset: UIEdgeInsets(top: 0, left: 30, bottom: -25, right: -30))
    submitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
  }
  
  @objc func submitButtonTapped() {
    buttonHandler?()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
