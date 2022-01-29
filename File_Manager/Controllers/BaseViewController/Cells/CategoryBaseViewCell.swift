//
//  CategoryBaseViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 29.01.2022.
//

import UIKit

class CategoryBaseViewCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  lazy private var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoMedium)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .left
    label.textColor = .darkGray
    label.text = Texts.baseCategoryLabelText
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
    
}

extension CategoryBaseViewCell {
  func configure() {
    contentView.addSubview(titleLabel)
    titleLabel.addEdgeContstraints(exclude: .bottom, offset: UIEdgeInsets(top: 5, left: 16, bottom: 0, right: -16))
  }
}
