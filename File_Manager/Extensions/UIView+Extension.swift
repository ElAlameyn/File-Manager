//
//  UITableView+Extension.swift
//  Musical_Player_v2.0
//
//  Created by Артем Калинкин on 25.12.2021.
//

import UIKit

extension UIView
{
  // MARK: - Layout
  
  enum AnchorType {
    case top, bottom, left, right
  }
  
  enum AnchorCenterType {
    case axisX, axisY
  }
  
  enum HeightWidthType {
    case width, height
  }
  
  func addEdgeContstraints(exclude: AnchorType..., offset: UIEdgeInsets? = nil) {
    guard let superview = superview else { return }
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if !exclude.contains(.top) {
      topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: offset?.top ?? 0).isActive = true
    }
    
    if !exclude.contains(.bottom) {
      bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: offset?.bottom ?? 0).isActive = true
    }
    
    if !exclude.contains(.left) {
      leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor, constant: offset?.left ?? 0).isActive = true
    }
    
    if !exclude.contains(.right) {
      rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor, constant: offset?.right ?? 0).isActive = true
    }
  }
  
  func addCenterConstraints(exclude: AnchorCenterType..., offset: CGPoint? = nil) {
    guard let superview = superview else { return }
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if !exclude.contains(.axisY) {
      centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: offset?.y ?? 0).isActive = true
    }
    
    if !exclude.contains(.axisX) {
      centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: offset?.x ?? 0).isActive = true
    }
  }
  
  func addHeightWeightConstraints(exclude: HeightWidthType..., values: CGPoint? = nil) {
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if !exclude.contains(.height) {
      heightAnchor.constraint(equalToConstant: values?.y ?? 0).isActive = true
    }
    
    if !exclude.contains(.width) {
      widthAnchor.constraint(equalToConstant: values?.x ?? 0).isActive = true
    }
    
  }
  
  // MARK: - Animations
  
  func animateClick(completion: @escaping () -> Void) {
      UIView.animate(withDuration: 0.15) {
          self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      } completion: { _ in
          UIView.animate(withDuration: 0.15) {
              self.transform = CGAffineTransform.identity
          } completion: { _ in completion() }
      }
  }

}
