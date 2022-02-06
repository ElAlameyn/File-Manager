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
  
  lazy private var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoMediumForCategories)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .darkGray
    label.text = Texts.baseCategoryLabelText
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
  
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
    layer.cornerRadius = 20
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowRadius = 2
    layer.shadowOpacity = 0.3
    
    // MARK: - Layout
    
    contentView.addSubview(imageView)
    imageView.addHeightWeightConstraints(offset: CGPoint(x: 70, y: 70))
    imageView.addCenterConstraints(offset: CGPoint(x: 0, y: -10))
    
    contentView.addSubview(titleLabel)
    titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 1).isActive = true
    titleLabel.addEdgeContstraints(exclude: .bottom, .top, offset: UIEdgeInsets(top: 5, left: 16, bottom: 0, right: -16))
  }
}
