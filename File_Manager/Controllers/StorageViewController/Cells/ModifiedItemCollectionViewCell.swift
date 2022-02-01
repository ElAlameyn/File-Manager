//
//  ModifiedItemCollectionViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

class ModifiedItemCollectionViewCell: UICollectionViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoRegular.withSize(13))
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .left
    label.textColor = Colors.labelGrayColor
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
  
  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  lazy var descrButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(
      systemName: "ellipsis",
      withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))?
                      .withTintColor(.black, renderingMode: .alwaysOriginal),
                    for: .normal)
    button.setTitle("", for: .normal)
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // MARK: - Layout
    
    backgroundColor = .white
    layer.cornerRadius = 10
    layer.shadowOffset = CGSize(width: 1, height: 5)
    layer.shadowRadius = 2
    layer.shadowOpacity = 0.1
    
    contentView.addSubview(imageView)
    imageView.addCenterConstraints(exclude: .axisX)
    imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
//    imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
    imageView.addHeightWeightConstraints(offset: CGPoint(x: 40, y: 40))
    
    contentView.addSubview(descrButton)
    descrButton.addCenterConstraints(exclude: .axisX)
    descrButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
    descrButton.addHeightWeightConstraints(offset: CGPoint(x: 25, y: 25))
    
    descrButton.addTarget(self, action: #selector(descrButtonTapped), for: .touchUpInside)
    
    contentView.addSubview(titleLabel)
    titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: descrButton.leftAnchor,constant: -10).isActive = true
//    titleLabel.addCenterConstraints(exclude: .axisX)
    titleLabel.addEdgeContstraints(exclude: .left, .right, offset: UIEdgeInsets(top: 20, left: 0, bottom: -20, right: 0))
  }
  
  @objc func descrButtonTapped() {
    print("Tapped")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
