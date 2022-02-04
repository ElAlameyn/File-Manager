//
//  CustomTabItemView.swift
//  File_Manager
//
//  Created by Артем Калинкин on 04.02.2022.
//

import UIKit


class CustomTabItemView: UIView {
  
  private let item: CustomTabItem
  let index: Int
  
  private let containerView = UIView()
  
  var isSelected = false {
    didSet {
      animateItems()
    }
  }
  
  lazy private var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoMediumForCategories.withSize(12))
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 1
    label.textAlignment = .center
    label.textColor = .white
    label.text = item.name
    label.addCharacterSpacing(kernValue: -0.33)
//    label.isHidden = true
    return label
  }()
  
  private let imageView = UIImageView()
  
  init(with item: CustomTabItem, index: Int) {
    self.item = item
    self.index = index
    
    super.init(frame: CGRect.zero)
    
    setUpUI()
  }
  
  private func setUpUI() {
    imageView.image = item.icon
    
//    containerView.frame = self.bounds
    
    layer.borderWidth = 1
    layer.borderColor = UIColor.black.cgColor
    
    self.addSubview(containerView)
    containerView.addEdgeContstraints()
    containerView.addCenterConstraints()
    
    containerView.addSubview(titleLabel)

    NSLayoutConstraint.activate([
      titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
      titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
    ])
    

    containerView.addSubview(imageView)
      imageView.addHeightWeightConstraints(offset: CGPoint(x: 35, y: 35))
    
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      imageView.topAnchor.constraint(equalTo: self.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
    ])
  }
  
  private func animateItems() {
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
