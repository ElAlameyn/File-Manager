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
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoMedium)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = Colors.labelBlueColor
    label.text = Texts.meetTitleLabelText
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
  
  lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoRegular)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .systemGray
    label.text = Texts.meetDescriptionLabelText
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
  
  lazy var submitButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 20
    button.backgroundColor = Colors.buttonBlueColor
    button.titleLabel?.font = Fonts.robotoBold
    button.setTitleColor(.white, for: .normal)
    button.setTitle(Texts.meetButtonTitle, for: .normal)
    return button
  }()
  
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
