//
//
//  FilesDetailViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit
import Combine

class FilesDetailViewCell: UICollectionViewCell {
  
  private var activityView: UIActivityIndicatorView?
  private var cancellables = Set<AnyCancellable>()
  
  var label = UILabel.withStyle(Style.label.desriptionGray)
  
  var mainImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.image = Images.categoryFiles
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
  }
  
  func configure(title: String) {
    label.text = title
  }
  
  private lazy var borderView: UIView = {
    let borderView = UIView()
    borderView.frame = self.bounds
    borderView.layer.cornerRadius = 20
    borderView.layer.masksToBounds = true
    borderView.backgroundColor = .white
    return borderView
  }()
  
  private func setUpUI() {
    backgroundColor = .white
    
    Style.withShadow(withRadius: 1, offset: CGSize(width: 0, height: 5), opacity: 0.2)(self)
    
    layer.shadowColor = UIColor.black.cgColor 
    layer.cornerRadius = 20
    clipsToBounds = true
    

    addSubview(mainImageView)
    mainImageView.addEdgeContstraints(exclude: .bottom, offset: UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10))
    mainImageView.addHeightWeightConstraints(exclude: .width, values: CGPoint(x: 80, y: 90))

    addSubview(label)
    label.addEdgeContstraints(exclude: .top, offset: UIEdgeInsets(top: 40, left: 5, bottom: -5, right: -5))
    label.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 40).isActive = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}



