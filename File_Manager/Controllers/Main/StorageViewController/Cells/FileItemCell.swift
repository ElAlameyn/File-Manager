//
//  ModifiedItemCollectionViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit
import UniformTypeIdentifiers

protocol HandlingFileMenuOperations {
  func didShareTapped(for indexPath: IndexPath)
  func didMoveToTapped(for indexPath: IndexPath)
  func didCopyToTapped(for indexPath: IndexPath)
  func didDeleteTapped(for indexPath: IndexPath)
}

class FileItemCell: UICollectionViewCell {
  
  var handleMenu: HandlingFileMenuOperations?
  var indexPath: IndexPath?
  
  private let titleLabel = UILabel.withStyle(
    Style.baseLabelStyle <>
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
    button.menu = addFileMenu()
    button.showsMenuAsPrimaryAction = true
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setUpUI()
    setUpLayout()
  }
  
  func configure(
    title: String? = nil,
    image: UIImage? = nil,
    tag: String? = nil
  ) {
    guard let title = title else { return }
    titleLabel.text = title
    tag == "folder" ? imageView.image = Images.categoryFolder : imageView.setCategoryFor(file: title)
  }
  
  private func addFileMenu() -> UIMenu {
    UIMenu(
      title: "What to do with file",
      image: nil,
      identifier: .file,
      options: [],
      children:[
        UIAction(
          title: "Share",
          image: UIImage(systemName: "square.and.arrow.up"),
          handler: { [weak self] _ in
            guard let self = self, let indexPath = self.indexPath else { return }
            self.handleMenu?.didShareTapped(for: indexPath)
          }),
        UIAction(
          title: "Move to",
          image: UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right"),
          handler: { [weak self] _ in
            guard let self = self, let indexPath = self.indexPath else { return }
            self.handleMenu?.didMoveToTapped(for: indexPath)
          }),
        UIAction(
          title: "Copy to",
          image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"),
          handler: { [weak self] _ in
            guard let self = self, let indexPath = self.indexPath else { return }
            self.handleMenu?.didCopyToTapped(for: indexPath)
          }),
        UIAction(
          title: "Delete",
          image: UIImage(systemName: "trash"),
          attributes: [.destructive],  handler: { [weak self] _ in
            guard let self = self, let indexPath = self.indexPath else { return }
            self.handleMenu?.didDeleteTapped(for: indexPath)
          })
      ])
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
  }
  
  private func setUpContentView() {
    backgroundColor = .white
    layer.cornerRadius = 10
    layer.shadowOffset = CGSize(width: 1, height: 5)
    layer.shadowRadius = 2
    layer.shadowOpacity = 0.1
  }
  
  private func setUpLayout() {
    imageView.addCenterConstraints(exclude: .axisX)
    imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
    imageView.addHeightWeightConstraints(values: CGPoint(x: 40, y: 40))
    
    descrButton.addCenterConstraints(exclude: .axisX)
    descrButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
    descrButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    descrButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    
    titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: descrButton.leftAnchor,constant: -10).isActive = true
    titleLabel.addEdgeContstraints(exclude: .left, .right, offset: UIEdgeInsets(top: 20, left: 0, bottom: -20, right: 0))
  }
}



