//
//  TitleBaseViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 29.01.2022.
//

import UIKit

class TitleBaseViewCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var titleLabel = UILabel.withStyle(f: Style.titleBaseViewCell)
  
  private var descriptionLabel = UILabel.withStyle(f: Style.descriptionBaseViewCell)

}

extension TitleBaseViewCell {
  func configure() {
    contentView.addSubview(titleLabel)
    titleLabel.addEdgeContstraints(exclude: .bottom, offset: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: -30))
    
    contentView.addSubview(descriptionLabel)
    descriptionLabel.addEdgeContstraints(exclude: .bottom, .top, offset: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -16))
    descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
  }
}

