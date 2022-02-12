//
//  RecentBaseViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

class RecentBaseViewCell: UICollectionViewCell {
  private var leftUpperImageView = UIImageView(image: UIImage(systemName: "heart"))
  private var bottomRightView = UIImageView(image: UIImage(systemName: "photo.fill"))

  private var isLiked = false
  
  var mainImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  lazy var borderView: UIView = {
    let borderView = UIView()
    borderView.frame = self.bounds
    borderView.layer.cornerRadius = 20
    borderView.layer.masksToBounds = true
    return borderView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
  }
  
  func configure(image: UIImage? = nil) {
    if let image = image {
      mainImageView.image = ImageTransformator.scaled(image: image)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecentBaseViewCell {
  private func setUpUI() {
    
    // MARK: - Layout
    
    Style.withShadow(withRadius: 1, offset: CGSize(width: 0, height: 5), opacity: 0.2)(self)
    
    addSubview(borderView)

    mainImageView.frame = borderView.bounds
    borderView.addSubview(mainImageView)
    
    leftUpperImageView.tintColor = .white
    mainImageView.addSubview(leftUpperImageView)
    leftUpperImageView.addEdgeContstraints(exclude: .bottom, .right, offset: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0))
    leftUpperImageView.addHeightWeightConstraints(values: CGPoint(x: 25, y: 25))

    bottomRightView.tintColor = .lightGray
    mainImageView.addSubview(bottomRightView)
    bottomRightView.addEdgeContstraints(exclude: .top, .left, offset: UIEdgeInsets(top: 0, left: 0, bottom: -10, right: -10))
  }
  
  @objc func likedTapped(_ sender: UITapGestureRecognizer) {
    print("tapped")
    isLiked.toggle()
    leftUpperImageView.image = isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
  }

}
