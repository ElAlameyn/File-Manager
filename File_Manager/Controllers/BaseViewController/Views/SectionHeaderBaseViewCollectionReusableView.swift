//
//  SectionHeaderBaseViewCollectionReusableView.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

class SectionHeaderBaseViewCollectionReusableView: UICollectionReusableView
{
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoMedium).withSize(25)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 1
    label.textAlignment = .left
    label.textColor = .darkGray
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    label.text = Texts.baseTitleLabelText
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = Colors.baseBackground

    self.addSubview(titleLabel)
    titleLabel.addEdgeContstraints(exclude: .right, offset: UIEdgeInsets(top: 10, left: 10, bottom: -10, right: 0))

  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
