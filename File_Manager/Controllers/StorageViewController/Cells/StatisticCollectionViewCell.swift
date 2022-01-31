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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
