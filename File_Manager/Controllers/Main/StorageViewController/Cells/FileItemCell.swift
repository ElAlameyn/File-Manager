//
//  ModifiedItemCollectionViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit
import UniformTypeIdentifiers

class FileItemCell: UICollectionViewCell {
  
  private let titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoRegular.withSize(18),
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
  
  func configureBackCell() {
    titleLabel.text = ""
    descrButton.isHidden = true
    imageView.image = UIImage(systemName: "arrow.backward")?.withPointSize(30).withTintColor(.black)
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FileItemCell {
  
  private func setUpUI() {
    setUpContentView()
    contentView.addSubview(imageView)
    contentView.addSubview(descrButton)
    contentView.addSubview(titleLabel)
    descrButton.addTarget(self, action: #selector(descrButtonTapped), for: .touchUpInside)
  }

  private func setUpContentView() {
    backgroundColor = .white
    layer.cornerRadius = 10
    layer.shadowOffset = CGSize(width: 1, height: 5)
    layer.shadowRadius = 2
    layer.shadowOpacity = 0.1
  }

  func setUpLayout() {
    descrButton.removeConstraints(descrButton.constraints)
    titleLabel.removeConstraints(titleLabel.constraints)
    
    imageView.addCenterConstraints(exclude: .axisX)
    imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
    imageView.addHeightWeightConstraints(values: CGPoint(x: 40, y: 40))
    
    descrButton.addCenterConstraints(exclude: .axisX)
    descrButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
    descrButton.addHeightWeightConstraints(values: CGPoint(x: 25, y: 25))

    titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: descrButton.leftAnchor,constant: -10).isActive = true
    titleLabel.addEdgeContstraints(exclude: .left, .right, offset: UIEdgeInsets(top: 20, left: 0, bottom: -20, right: 0))
  }
  
}
