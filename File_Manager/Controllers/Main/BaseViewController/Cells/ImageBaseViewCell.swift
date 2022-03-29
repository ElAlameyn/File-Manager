//
//  RecentBaseViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit
import Combine

class ImageBaseViewCell: UICollectionViewCell {
  private var leftUpperImageView = UIImageView(
    image: UIImage(systemName: "heart")
  )
  private var bottomRightView = UIImageView(
    image: UIImage(systemName: "photo.fill")
  )
  private var activityView: UIActivityIndicatorView?
  private var cancellables = Set<AnyCancellable>()
  
  private var imageViewModel = ImageViewModel()
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
    
    DropboxAPI.shared.fetchDownload(id: id)?
      .sink(receiveCompletion: {
        switch $0 {
        case .finished: break
        case .failure(let error):
          print("Image failed to load due to", error)
        }
      }, receiveValue: {
        self.imageViewModel.value.send($0)
      }).store(in: &cancellables)
    
    imageViewModel.value.sink(receiveCompletion: {_ in}, receiveValue: { [weak self] value in
      if value != nil {
        self?.hideActivityIndicator()
        self?.mainImageView.image = self?.imageViewModel.image
        self?.isFethed = true
      }
    }).store(in: &cancellables)
  }
  
  @objc func likedTapped(_ sender: UITapGestureRecognizer) {
    isLiked.toggle()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ImageBaseViewCell {
  
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

extension ImageBaseViewCell {
  
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
