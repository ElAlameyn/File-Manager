//
//  ImageScrollView.swift
//  File_Manager
//
//  Created by Артем Калинкин on 12.03.2022.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
  
  private var imageView: UIImageView!
  
  var didEndZooming: Empty?
  var didStartZooming: Empty?
  
  var getImage: UIImage? {
    imageView != nil && imageView.image != nil ? imageView.image : nil
  }
  
  private var currentScale: CGFloat = 0
  
  private lazy var zoomingTap: UITapGestureRecognizer = {
    let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
    zoomingTap.numberOfTapsRequired = 2
    return zoomingTap
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    delegate = self
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    decelerationRate = UIScrollView.DecelerationRate.fast
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func handleZoomingTap(sender: UITapGestureRecognizer) {
    let location = sender.location(in: sender.view)
    zoom(to: location, animated: true)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    centerImage()
  }
  
  func set(image: UIImage?) {
    imageView?.removeFromSuperview()
    imageView = nil
    
    imageView = UIImageView(image: image)
    addSubview(imageView)
    
    currentScale = zoomScale
    configure(imageSize: image?.size)
  }
  
  private func configure(imageSize: CGSize?) {
    guard let imageSize = imageSize else { return }
    contentSize = imageSize
    setCurrentZoomScale()
    zoomScale = minimumZoomScale
    
    imageView.addGestureRecognizer(zoomingTap)
    imageView.isUserInteractionEnabled = true
  }
  
  // MARK: - PRIVATE

  private func zoom(to point: CGPoint, animated: Bool) {
    let currentScale = zoomScale
    let minScale = minimumZoomScale
    let maxScale = maximumZoomScale
    
    if minScale == maxScale && minScale > 1 { return }
    let toScale = maximumZoomScale
    let finalScale = (currentScale == minScale) ? toScale : minScale
    let zoomRect = zoomRect(scale: finalScale, center: point)
    zoom(to: zoomRect, animated: animated)
  }
  
  private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
    var zoomRect = CGRect.zero
    let bounds = bounds
    
    zoomRect.size.width = bounds.size.width / scale
    zoomRect.size.height = bounds.size.height / scale
    
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
    return zoomRect
  }


  private func setCurrentZoomScale() {
    let boundsSize = bounds.size
    let imageSize = imageView.bounds.size
    
    let xScale = boundsSize.width / imageSize.width
    let yScale = boundsSize.height / imageSize.height
    let minScale = min(xScale, yScale)
    
    var maxScale: CGFloat = 1
    
    switch minScale {
    case _ where minScale < 0.1: maxScale = 0.3
    case _ where minScale >= 0.1 && minScale < 0.5: maxScale = 0.7
    case _ where minScale >= 0.5: maxScale = max(1.0, minScale)
    default: break
    }
    
    minimumZoomScale = minScale
    maximumZoomScale = maxScale
  }
  

  private func centerImage() {
    let boundsSize = bounds.size
    var frameCenter = imageView?.frame ?? .zero
    
    if frameCenter.size.width < boundsSize.width {
      frameCenter.origin.x = (boundsSize.width - frameCenter.size.width) / 2
    } else {
      frameCenter.origin.x = 0
    }
    
    if frameCenter.size.height < boundsSize.height {
      frameCenter.origin.y = (boundsSize.height - frameCenter.size.height) / 2
    } else {
      frameCenter.origin.y = 0
    }
    
    imageView?.frame = frameCenter
  }
  
  // MARK: - UIScrollViewDelegate
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    centerImage()
  }
  
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    if zoomScale == minimumZoomScale {
      didEndZooming?()
    }
  }
  
  func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    didStartZooming?()
  }
  

}
