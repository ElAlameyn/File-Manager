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
    Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMediumForCategories,
      color: .darkGray,
      text: Texts.baseCategoryLabelText))
  
  func configure(title: String? = nil, amount: Int? = nil ) {
    guard let title = title, let amount = amount else { return }
    titleLabel.text = "\(title) \(amount)"
    imageView.setCategoryFor(name: title)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
    setUpLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CategoryBaseViewCell {
  private func setUpUI() {
    backgroundColor = .white
    
    Style.withShadow(withRadius: 2,
                     offset: CGSize(width: 0, height: 5),
                     opacity: 0.3) (self)
    Style.rounded(radius: 20)(self)

    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)
  }
  
  private func setUpLayout() {
    imageView.addHeightWeightConstraints(values: CGPoint(x: 70, y: 70))
    imageView.addCenterConstraints(offset: CGPoint(x: 0, y: -10))
    
    titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 1).isActive = true
    titleLabel.addEdgeContstraints(exclude: .bottom, .top, offset: UIEdgeInsets(top: 5, left: 16, bottom: 0, right: -16))
  }
}
