//
//  StatisticCollectionViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

class StatisticCollectionViewCell: UICollectionViewCell {
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    layer.cornerRadius = 26
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowRadius = 4
    layer.shadowOpacity = 0.2
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
