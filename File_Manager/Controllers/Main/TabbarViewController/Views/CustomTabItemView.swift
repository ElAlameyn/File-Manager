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
  
  private var isChanged = false
  
  lazy private var titleLabel = UILabel.withStyle(
    Style.concat(
      Style.baseLabelStyle,
      Style.appearanceLabelStyle(
        withFont: Fonts.robotoMediumForCategories.withSize(14),
        color: .white,
        text: item.name),
      Style.mask
    )
  )
  
  private let imageView = UIImageView()
  
  init(with item: CustomTabItem, index: Int) {
    self.item = item
    self.index = index
    
    super.init(frame: CGRect.zero)
    
    setUpUI()
  }
  
  private func setUpUI() {
    imageView.image = item.icon
    
    self.addSubview(containerView)
    containerView.addEdgeContstraints()
    containerView.addCenterConstraints()
    
    containerView.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
      titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5),
    ])
    
    titleLabel.alpha = 0.0
    
    containerView.addSubview(imageView)
    imageView.addHeightWeightConstraints(values: CGPoint(x: 30, y: 30))
    
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    
  }
  
  private func animateItems() {
    if isSelected {
      if isChanged { return }
      UIView.animate(withDuration: 0.8, animations: {
        self.imageView.transform = CGAffineTransform(translationX: 0, y: -15)
        self.isChanged = true
        self.titleLabel.alpha = 1.0
      })
    } else {
      if isChanged {
        UIView.animate(withDuration: 0.8, animations: {
          self.imageView.transform = CGAffineTransform(translationX: 0, y: 0)
          self.titleLabel.alpha = 0.0
        })
        self.isChanged = false
      }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
