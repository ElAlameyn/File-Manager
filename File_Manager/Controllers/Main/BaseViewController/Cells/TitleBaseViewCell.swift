//
//  TitleBaseViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 29.01.2022.
//

import UIKit

class TitleBaseViewCell: UICollectionViewCell {
  
  var titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMedium.withSize(26),
      color: .darkGray,
      text: Texts.baseTitleLabelText)
    <> {
      $0.textAlignment = .left
    })
  
  var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .lightGray
    imageView.clipsToBounds = true
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
  }
  
  func configure(image: UIImage? = nil, text: String? = nil) {
    titleLabel.text = text
    imageView.image = image
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TitleBaseViewCell {
  func setUpUI() {
    contentView.addSubview(imageView)
    imageView.addEdgeContstraints(exclude: .bottom, .left, .top, offset: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: -16))
    imageView.addHeightWeightConstraints(values: CGPoint(x: 50, y: 50))
    imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    Style.rounded(radius: 25)(imageView)
    
    contentView.addSubview(titleLabel)
    titleLabel.addEdgeContstraints(exclude: .bottom, .right, offset: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: -30))
    titleLabel.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -5).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
  }
}

