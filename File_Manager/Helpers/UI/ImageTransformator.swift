//
//  ImageTransformator.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

final class ImageTransformator {
  static func scaled(image: UIImage) -> UIImage? {
    let size = image.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
    let hasAlpha = false
    let scale: CGFloat = 0.0

    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    image.draw(in: CGRect(origin: .zero, size: size))

    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }
}
