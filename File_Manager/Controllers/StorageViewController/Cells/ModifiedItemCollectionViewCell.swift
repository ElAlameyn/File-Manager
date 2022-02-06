//
//  ModifiedItemCollectionViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

class ModifiedItemCollectionViewCell: UICollectionViewCell {
  
  private let titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <>
    Style.appearanceLabelStyle(withFont: Fonts.robotoRegular.withSize(13),
                         color: Colors.labelGrayColor,
                         text: "???")
    <> {
      $0.textAlignment = .left
    })
  
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
  
  func configure(title: String? = nil, image: UIImage? = nil) {
    titleLabel.text = title
    imageView.image = image
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
  }
  
  @objc func descrButtonTapped() {
    print("Tapped")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ModifiedItemCollectionViewCell {
  private func setUpUI() {
    backgroundColor = .white
    layer.cornerRadius = 10
    layer.shadowOffset = CGSize(width: 1, height: 5)
    layer.shadowRadius = 2
    layer.shadowOpacity = 0.1
    
    contentView.addSubview(imageView)
    imageView.addCenterConstraints(exclude: .axisX)
    imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
    imageView.addHeightWeightConstraints(offset: CGPoint(x: 40, y: 40))
    
    contentView.addSubview(descrButton)
    descrButton.addCenterConstraints(exclude: .axisX)
    descrButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
    descrButton.addHeightWeightConstraints(offset: CGPoint(x: 25, y: 25))
    
    descrButton.addTarget(self, action: #selector(descrButtonTapped), for: .touchUpInside)
    
    contentView.addSubview(titleLabel)
    titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: descrButton.leftAnchor,constant: -10).isActive = true
    titleLabel.addEdgeContstraints(exclude: .left, .right, offset: UIEdgeInsets(top: 20, left: 0, bottom: -20, right: 0))
  }
}
