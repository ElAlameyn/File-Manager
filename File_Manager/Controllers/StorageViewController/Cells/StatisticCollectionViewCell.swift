//
//  StatisticCollectionViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

class StatisticCollectionViewCell: UICollectionViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoRegular.withSize(27))
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .left
    label.textColor = Colors.buttonBlueColor
    label.addCharacterSpacing(kernValue: -0.33)
    return label
  }()
  
  private func getAngleOf(percent: Int) -> CGFloat {
    guard percent != 100 else { return .pi * 2}
    guard percent != 0 else { return -(.pi / 2)}

    var computablePercent = Double(percent)
    let startAngle = (-Float.pi / 2)
    if computablePercent < 25 {
      return CGFloat(startAngle - (startAngle * Float(computablePercent)) / 25)
    } else if computablePercent == 25 {
      return 0
    } else {
      let endAngle = 3 * (Float.pi / 2)
      computablePercent -= 25
      return CGFloat(endAngle * Float(computablePercent) / 75)
    }
  }
    
  let shape = CAShapeLayer()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    layer.cornerRadius = 26
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowRadius = 4
    layer.shadowOpacity = 0.2
    
    contentView.addSubview(titleLabel)
    titleLabel.center = contentView.center
    
    let circlePath = UIBezierPath(arcCenter: contentView.center,
                                  radius: contentView.bounds.width / 2 - 44,
                                  startAngle: -(.pi / 2),
                                  endAngle: .pi * 2 , clockwise: true)
    
    let trackShape = CAShapeLayer()
    trackShape.path = circlePath.cgPath
    trackShape.fillColor = UIColor.clear.cgColor
    trackShape.lineWidth = 35
    trackShape.strokeColor = UIColor.lightGray.cgColor
    contentView.layer.addSublayer(trackShape)

    let shapePath = UIBezierPath(arcCenter: contentView.center,
                                  radius: contentView.bounds.width / 2 - 44,
                                 startAngle: -(.pi / 2),
                                 endAngle: getAngleOf(percent: 37), clockwise: true)
    
    shape.path = shapePath.cgPath
    shape.lineWidth = 35
    shape.strokeColor = Colors.buttonBlueColor.cgColor
    shape.fillColor = UIColor.clear.cgColor
    shape.strokeStart = 0
    shape.strokeEnd = 1
    contentView.layer.addSublayer(shape)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

}
