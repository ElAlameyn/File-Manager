//
//  StatisticCollectionViewCell.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

class StatisticCollectionViewCell: UICollectionViewCell {

  private let statisticLabelStyle =
    Style.baseLabelStyle <> Style.mask <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMedium.withSize(22),
      color: Colors.labelStatisticColor,
      text: "???")
    
  private let statisticDescriptionLabelStyle =
    Style.baseLabelStyle <> Style.mask <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoMediumForCategories.withSize(15),
      color: Colors.labelGrayColor,
      text: "???")
  
  lazy private var usedLabel = UILabel.withStyle(f: statisticLabelStyle)
  lazy private var totalLabel = UILabel.withStyle(f: statisticLabelStyle)
  lazy private var availableLabel = UILabel.withStyle(
    f: statisticLabelStyle <>
    { $0.font = UIFontMetrics.default.scaledFont(
      for: Fonts.robotoMedium.withSize(25))})
  
  lazy private var usedDescriptionLabel = UILabel.withStyle(
    f: statisticDescriptionLabelStyle <>
    { $0.text = "Used"})
  lazy private var totalDescriptionLabel = UILabel.withStyle(
    f: statisticDescriptionLabelStyle <>
    { $0.text = "Total"})
  lazy private var availableDescriptionLabel = UILabel.withStyle(
    f: statisticDescriptionLabelStyle <>
    { $0.text = "Available"})

  private func getValueOf(percent: Int) -> CGFloat {
    let endAngle = (4 * CGFloat.pi / 2)
    let startAngle = (3 * CGFloat.pi / 2)
    return CGFloat(startAngle + (endAngle * CGFloat(percent)) / 100)
  }

  let shape: CAShapeLayer = {
    let shape = CAShapeLayer()
    shape.lineWidth = 35
    shape.strokeColor = Colors.buttonBlueColor.cgColor
    shape.fillColor = UIColor.clear.cgColor
    shape.strokeStart = 0
    shape.strokeEnd = 1
    return shape
  }()
  
  private var circleRadius: CGFloat {
    contentView.bounds.width / 2 - 44
  }
  
  private var circleCenter: CGPoint {
    CGPoint(x: contentView.center.x, y: contentView.center.y - 30)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureShadow()
    addShapes()
    setUpUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(statistic: Statistic? = nil) {
    if let statistic = statistic {
      usedLabel.text = "\(statistic.usedMemory) GB"
      availableLabel.text = "\(statistic.emptyMemory) GB"
      totalLabel.text = "\(statistic.totalMemory) GB"
      
      let shapePath = UIBezierPath(
        arcCenter: circleCenter,
        radius: circleRadius,
        startAngle: 3 * .pi / 2,
        endAngle: getValueOf(percent: statistic.usedMemory * 100 / statistic.totalMemory),
        clockwise: true)
      
      shape.path = shapePath.cgPath
    }
    
  }
  
  private func addShapes() {
    let circlePath = UIBezierPath(
      arcCenter: circleCenter,
      radius: circleRadius,
      startAngle: -(.pi / 2),
      endAngle: .pi * 2 ,
      clockwise: true)
    
    addTrackShape(at: circlePath)

    let shapePath = UIBezierPath(
      arcCenter: circleCenter,
      radius: circleRadius,
      startAngle: 3 * .pi / 2,
      endAngle: getValueOf(percent: 50),
      clockwise: true)
    
    shape.path = shapePath.cgPath
    contentView.layer.addSublayer(shape)
  }
  
  private func setUpUI() {
    contentView.addSubview(usedLabel)
    usedLabel.addEdgeContstraints(exclude: .right, .top, offset: UIEdgeInsets(top: 0, left: 25, bottom: -20, right: 0))
    
    contentView.addSubview(totalLabel)
    totalLabel.addEdgeContstraints(exclude: .left, .top, offset: UIEdgeInsets(top: 0, left: 0, bottom: -20, right: -25))
    
    contentView.addSubview(totalDescriptionLabel)
    NSLayoutConstraint.activate([
      totalDescriptionLabel.bottomAnchor.constraint(equalTo: totalLabel.topAnchor, constant: -8),
      totalDescriptionLabel.rightAnchor.constraint(equalTo: totalLabel.rightAnchor),
      totalDescriptionLabel.leftAnchor.constraint(equalTo: totalLabel.leftAnchor)
    ])
    
    contentView.addSubview(usedDescriptionLabel)
    NSLayoutConstraint.activate([
      usedDescriptionLabel.bottomAnchor.constraint(equalTo: usedLabel.topAnchor, constant: -8),
      usedDescriptionLabel.leftAnchor.constraint(equalTo: usedLabel.leftAnchor),
      usedDescriptionLabel.rightAnchor.constraint(equalTo: usedLabel.rightAnchor)
    ])
    
    contentView.addSubview(availableDescriptionLabel)
    availableDescriptionLabel.addCenterConstraints(offset: CGPoint(x: 0, y: -5))
    
    contentView.addSubview(availableLabel)
    NSLayoutConstraint.activate([
      availableLabel.bottomAnchor.constraint(equalTo: availableDescriptionLabel.topAnchor, constant: -8),
      availableLabel.leftAnchor.constraint(equalTo: availableDescriptionLabel.leftAnchor),
      availableLabel.rightAnchor.constraint(equalTo: availableDescriptionLabel.rightAnchor)
    ])
  }
  
  private func configureShadow() {
    backgroundColor = .white
    layer.cornerRadius = 26
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowRadius = 4
    layer.shadowOpacity = 0.2
  }
  
  private func addTrackShape(at path: UIBezierPath) {
    let trackShape = CAShapeLayer()
    trackShape.path = path.cgPath
    trackShape.fillColor = UIColor.clear.cgColor
    trackShape.lineWidth = 35
    trackShape.strokeColor = UIColor.systemGray5.cgColor
    contentView.layer.addSublayer(trackShape)
  }
  

}
