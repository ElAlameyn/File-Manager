//
//  ButtonViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 08.04.2022.
//

import UIKit
import Combine

class ButtonViewCell: UICollectionViewCell {
  var buttonHandler: Empty?
  private var subscriber: AnyCancellable?
  
  private var submitButton = UIButton.withStyle(
    Style.rounded(radius: 20) <>
    Style.configureButtonTitle(withTitle: "Upload", color: .white)
    <> {
      $0.backgroundColor = Colors.buttonBlueColor
      $0.titleLabel?.font = Fonts.robotoBold.withSize(20)
    })
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    subscriber = submitButton.publisher(for: .touchUpInside)
      .sink(receiveValue: {})
    
    setUpUI()
  }
  

  func setUpUI() {
    contentView.addSubview(submitButton)
    submitButton.addEdgeContstraints(offset: UIEdgeInsets(top: 0, left: 30, bottom: -25, right: -30))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
