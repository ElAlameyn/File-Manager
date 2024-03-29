//
//  ButtonStyles.swift.swift
//  File_Manager
//
//  Created by Артем Калинкин on 06.02.2022.
//

import UIKit

typealias Empty = (() -> Void)

struct Style {
  
  static let baseLabelStyle: (UILabel) -> Void = {
    $0.lineBreakMode = .byWordWrapping
    $0.textAlignment = .center
    $0.numberOfLines = 0
  }
  
  static func appearanceLabelStyle(
    withFont font: UIFont,
    color: UIColor,
    text: String? = "") -> (UILabel) -> Void {{
      $0.font = UIFontMetrics.default.scaledFont(for: font)
      $0.textColor = color
      $0.text = text
    }
    }
  
  static let mask: (UILabel) -> Void = {
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  static func rounded<V: UIView>(radius: CGFloat) -> (V) -> Void {{
    $0.layer.cornerRadius = radius
  }
  }
  
  static func withShadow(
    withRadius radius: CGFloat,
    offset: CGSize,
    opacity: Float) -> (UIView) -> Void {{
      $0.layer.shadowOffset = offset
      $0.layer.shadowRadius = radius
      $0.layer.shadowOpacity = opacity
    }
    }
  
  static func configureButtonTitle(
    withTitle title: String? = "",
    color: UIColor? = nil,
    image: UIImage? = nil) -> (UIButton) -> Void {{
      $0.setTitle(title, for: .normal)
      
      switch $0 {
      case _ where color != nil && image != nil:
        $0.setImage(image?.withTintColor(color!), for: .normal)
      case _ where color != nil:
        $0.setTitleColor(color, for: .normal)
      default:
        $0.setImage(image, for: .normal)
      }
    }
    }
  
  static func baseImageButtonStyle() -> (UIButton) -> Void {{
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
  }
  }
  
  static func concat<A>(_ fs: ((A) -> Void)...) -> (A) -> Void {
    { a in
      fs.forEach { f in f(a) }
    }
  }
}

extension Style {
  struct label {
    static let blueLargeTitle =
    Style.concat(
      Style.baseLabelStyle,
      Style.appearanceLabelStyle(
        withFont: Fonts.robotoMedium.withSize(26),
        color: Colors.labelBlueColor,
        text: Texts.meetTitleLabelText)
    )
    
    static let desriptionGray =
    Style.concat(
      Style.baseLabelStyle,
      Style.appearanceLabelStyle(
        withFont: Fonts.robotoRegular.withSize(20),
        color: .systemGray,
        text: Texts.meetDescriptionLabelText)
    )
  }
  
  struct button {
    static let blueButton =
    Style.concat(
      Style.rounded(radius: 20),
      Style.configureButtonTitle(withTitle: Texts.meetButtonTitle, color: .white) <>
       {
        $0.backgroundColor = Colors.buttonBlueColor
        $0.titleLabel?.font = Fonts.robotoBold
       }
    )
    
  }
  
}







