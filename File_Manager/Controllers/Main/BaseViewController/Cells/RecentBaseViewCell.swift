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
  private var activityView: UIActivityIndicatorView?
  
  private var imagesLoader = ImagesLoader()
  private var isLiked = false
  var isFethed = false

  var mainImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private lazy var borderView: UIView = {
    let borderView = UIView()
    borderView.frame = self.bounds
    borderView.layer.cornerRadius = 20
    borderView.layer.masksToBounds = true
    borderView.backgroundColor = .white
    return borderView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpUI()
    setUpLayout()
  }
  
  func fetch(id: String) {
    showActivityIndicator()
    imagesLoader.fetch(path: id) { [weak self] image in
      self?.hideActivityIndicator()
      self?.mainImageView.image = image
      self?.isFethed = true
    }
  }
  
  @objc func likedTapped(_ sender: UITapGestureRecognizer) {
    isLiked.toggle()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecentBaseViewCell {
  
  private func setUpUI() {
    addSubview(borderView)
    borderView.addSubview(mainImageView)
    mainImageView.addSubview(leftUpperImageView)
    mainImageView.addSubview(bottomRightView)
  }
  
  private func setUpLayout() {
    Style.withShadow(withRadius: 1, offset: CGSize(width: 0, height: 5), opacity: 0.2)(self)
    
    mainImageView.frame = borderView.bounds
    
    leftUpperImageView.tintColor = .white
    leftUpperImageView.addEdgeContstraints(
      exclude: .bottom, .right,
      offset: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
    )
    
    leftUpperImageView.addHeightWeightConstraints(values: CGPoint(x: 25, y: 25))
    
    bottomRightView.tintColor = .lightGray
    bottomRightView.addEdgeContstraints(
      exclude: .top, .left,
      offset: UIEdgeInsets(top: 0, left: 0, bottom: -10, right: -10)
    )
  }
  
}

extension RecentBaseViewCell {
  
  func showActivityIndicator() {
    activityView = UIActivityIndicatorView(style: .medium)
    activityView?.center = self.contentView.center
    contentView.addSubview(activityView!)
    activityView?.startAnimating()
  }
  
  func hideActivityIndicator(){
    if (activityView != nil){
      activityView?.stopAnimating()
    }
  }
}
