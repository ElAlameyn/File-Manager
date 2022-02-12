//
//  CategoryBaseViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 29.01.2022.
//

import UIKit

class CategoryBaseViewCell: UICollectionViewCell {

  lazy private var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private var titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMediumForCategories,
      color: .darkGray,
      text: Texts.baseCategoryLabelText))
  
  func configure(title: String? = nil, image: UIImage? = nil) {
    titleLabel.text = title
    imageView.image = image
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CategoryBaseViewCell {
  func setUpUI() {
    backgroundColor = .white
    
    Style.withShadow(withRadius: 2,
                     offset: CGSize(width: 0, height: 5),
                     opacity: 0.3) (self)
    Style.rounded(radius: 20)(self)


    // MARK: - Layout
    
    contentView.addSubview(imageView)
    imageView.addHeightWeightConstraints(values: CGPoint(x: 70, y: 70))
    imageView.addCenterConstraints(offset: CGPoint(x: 0, y: -10))
    
    contentView.addSubview(titleLabel)
    titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 1).isActive = true
    titleLabel.addEdgeContstraints(exclude: .bottom, .top, offset: UIEdgeInsets(top: 5, left: 16, bottom: 0, right: -16))
  }
}
