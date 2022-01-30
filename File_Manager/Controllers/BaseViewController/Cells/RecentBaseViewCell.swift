//
//  RecentBaseViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.01.2022.
//

import UIKit

class RecentBaseViewCell: UICollectionViewCell {
  var leftUpperImageView = UIImageView()
  var bottomRightView = UIImageView()
  
  var mainImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecentBaseViewCell {
  private func configure() {
    layer.masksToBounds = true
    layer.cornerRadius = 20
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowRadius = 4
    layer.shadowOpacity = 0.3
    
    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath

    // MARK: - Layout
//    contentView.addSubview(leftUpperImageView)
//    contentView.addSubview(bottomRightView)
    
    contentView.addSubview(mainImageView)
//    mainImageView.addEdgeContstraints(offset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    mainImageView.addHeightWeightConstraints(offset: CGPoint(x: 150, y: 220))
    mainImageView.addCenterConstraints()
  }
}
