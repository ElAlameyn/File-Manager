//
//  SectionHeaderBaseViewCollectionReusableView.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

protocol SortButtonDelegate {
  func sortButtonTapped()
}

class SectionHeaderBaseViewCollectionReusableView: UICollectionReusableView
{
  var delegate: SortButtonDelegate?
  
  lazy var descrButton: UIButton = {
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
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoMedium).withSize(25)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 1
    label.textAlignment = .left
    label.textColor = .darkGray
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    label.text = Texts.baseTitleLabelText
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = Colors.baseBackground

    self.addSubview(titleLabel)
    titleLabel.addEdgeContstraints(exclude: .right, offset: UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0))
    
    self.addSubview(descrButton)
    
    NSLayoutConstraint.activate([
      descrButton.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10),
      descrButton.centerYAnchor.constraint(equalTo: centerYAnchor),
      descrButton.topAnchor.constraint(equalTo: topAnchor)
    ])
    
    descrButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
  }
  
  @objc func sortButtonTapped() {
    delegate?.sortButtonTapped()
  }

  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}