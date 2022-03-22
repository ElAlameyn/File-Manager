//
//  ReturnFileCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 20.03.2022.
//

import UIKit

class ReturnFileCell: UICollectionViewCell {
  
  lazy private var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
    setUpLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ReturnFileCell {
  
  private func setUpUI() {
    imageView.image = UIImage(systemName: "arrow.backward")?
      .withPointSize(30)
      .withTintColor(.black)
    
    setUpContentView()
    contentView.addSubview(imageView)
  }
  
  private func setUpContentView() {
    backgroundColor = .white
    layer.cornerRadius = 10
    layer.shadowOffset = CGSize(width: 1, height: 5)
    layer.shadowRadius = 2
    layer.shadowOpacity = 0.1
  }
  
  func setUpLayout() {
    imageView.addCenterConstraints(exclude: .axisX)
    imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
    imageView.addHeightWeightConstraints(values: CGPoint(x: 40, y: 40))
  }
}
