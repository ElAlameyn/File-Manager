//
//  FoldersHeaderView.swift
//  File_Manager
//
//  Created by Артем Калинкин on 21.03.2022.
//

import UIKit

class FoldersHeaderView: UICollectionReusableView {
  
  private lazy var downArrowButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(
      systemName: "arrow.down",
      withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))?
      .withTintColor(.black, renderingMode: .alwaysOriginal),
                    for: .normal)
    button.setTitle("", for: .normal)
    button.isHidden = true
    return button
  }()
  
  lazy var titleLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <> Style.mask <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMedium.withSize(24),
      color: .darkGray,
      text: "")
    <> { $0.textAlignment = .left }
  )
  
  lazy var currentPathLabel = UILabel.withStyle(
    f: Style.baseLabelStyle <> Style.mask <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMedium.withSize(18),
      color: .darkGray,
      text: "Current Path: Root")
    <> {
      $0.isHidden = false
      $0.textAlignment = .left
    }
  )
  
  lazy var fileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.isUserInteractionEnabled = true
    imageView.image = Images.addFileImage
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  lazy var folderImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.isUserInteractionEnabled = true
    imageView.image = Images.addFolderImage
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = Colors.baseBackground
    self.isUserInteractionEnabled = true
        
    setUpLayout()
  }
  
  func setUpUI() {
    addSubview(folderImageView)
    addSubview(fileImageView)
    addSubview(titleLabel)
    addSubview(currentPathLabel)
    addSubview(downArrowButton)
    
    fileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddFile)))
    folderImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddFolder)))
  }
  
  func setUpLayout() {
    
    // folder image
    NSLayoutConstraint.activate([
      folderImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
      folderImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    folderImageView.addHeightWeightConstraints(values: CGPoint(x: 45, y: 45))

    // file image
    NSLayoutConstraint.activate([
      fileImageView.rightAnchor.constraint(equalTo: folderImageView.leftAnchor, constant: -5),
      fileImageView.bottomAnchor.constraint(equalTo: folderImageView.bottomAnchor, constant: -5)
    ])
    fileImageView.addHeightWeightConstraints(values: CGPoint(x: 35, y: 35))

    // title
    titleLabel.addEdgeContstraints(exclude: .right, .bottom, offset: UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0))
    titleLabel.rightAnchor.constraint(equalTo: fileImageView.leftAnchor, constant: -5).isActive = true
    
    // path label
    NSLayoutConstraint.activate([
      currentPathLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      currentPathLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      currentPathLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
      currentPathLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
    ])
    

    // sort button
    NSLayoutConstraint.activate([
      downArrowButton.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10),
      downArrowButton.topAnchor.constraint(equalTo: titleLabel.topAnchor)
    ])

  }
  
  @objc func didTapAddFolder() {
    // TODO: Add folder
  }
    
  @objc func didTapAddFile() {
    // TODO: Add file(paper)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
