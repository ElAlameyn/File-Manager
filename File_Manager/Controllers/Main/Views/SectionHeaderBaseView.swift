//
//  SectionHeaderBaseViewCollectionReusableView.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit


class SectionHeaderBaseView: UICollectionReusableView {

  lazy var downArrowButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(
      systemName: "arrow.down",
      withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))?
                      .withTintColor(.black, renderingMode: .alwaysOriginal),
                    for: .normal)
    button.setTitle("", for: .normal)
    button.isHidden = true
    return button
  }()
  
  lazy var titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <> Style.mask <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMedium.withSize(24),
      color: .darkGray,
      text: "")
    <> { $0.textAlignment = .left }
  )
  
  lazy var currentPathLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <> Style.mask <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMedium.withSize(18),
      color: .darkGray,
      text: "Current Path: Root")
    <> { $0.isHidden = false }
  ) 

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = Colors.baseBackground

    addSubview(titleLabel)
    titleLabel.addEdgeContstraints(exclude: .right, .bottom, offset: UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0))
    titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    
    addSubview(downArrowButton)
    
    NSLayoutConstraint.activate([
      downArrowButton.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10),
      downArrowButton.topAnchor.constraint(equalTo: titleLabel.topAnchor)
    ])
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
