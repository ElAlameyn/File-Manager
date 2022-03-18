//
//  LastModifiedCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 18.03.2022.
//

import UIKit

class LastModifiedCell: UICollectionViewCell {
  
  private let titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoRegular.withSize(16),
      color: Colors.labelGrayColor,
      text: "???")
    <> { $0.textAlignment = .left })
  
  lazy private var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  lazy private var descrButton: UIButton = {
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
    
    setUpUI()
    setUpLayout()
  }
  
  @objc func descrButtonTapped() {
    print("Tapped")
  }
  
  func configure(title: String? = nil,
                 image: UIImage? = nil,
                 tag: String? = nil
  ) {
    guard let title = title else { return }
    titleLabel.text = title
    if tag == "folder" {
      imageView.image = Images.categoryFolder
    } else {
      imageView.setCategoryFor(file: title)
    }
  }
  
  private func setUpUI() {
    setUpContentView()
    contentView.addSubview(imageView)
    contentView.addSubview(descrButton)
    contentView.addSubview(titleLabel)
    
    descrButton.transform = CGAffineTransform(rotationAngle: -.pi / 2)
    descrButton.addTarget(self, action: #selector(descrButtonTapped), for: .touchUpInside)
  }
  
   func setUpContentView() {
    backgroundColor = .white
    layer.cornerRadius = 10
    layer.shadowOffset = CGSize(width: 1, height: 5)
    layer.shadowRadius = 2
    layer.shadowOpacity = 0.1
  }
  
  func setUpLayout() {
    imageView.removeConstraints(imageView.constraints)
    descrButton.removeConstraints(descrButton.constraints)
    titleLabel.removeConstraints(titleLabel.constraints)
    
    imageView.addEdgeContstraints(exclude: .bottom, .right, offset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0))
    imageView.addHeightWeightConstraints(values: CGPoint(x: 40, y: 40))
    
    titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 7).isActive = true
    titleLabel.addEdgeContstraints(exclude: .top, offset: UIEdgeInsets(top: 0, left: 10, bottom: -10, right: -10))

    descrButton.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
    descrButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
    descrButton.leftAnchor.constraint(greaterThanOrEqualTo: imageView.leftAnchor, constant: 10).isActive = true
    descrButton.addHeightWeightConstraints(values: CGPoint(x: 25, y: 25))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

