//
//  DetailImageViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 09.03.2022.
//

import UIKit

class DetailImageController: UIViewController {
  
  private lazy var imageScrollView = ImageScrollView(frame: view.bounds)
  private var label = UILabel.withStyle(
  f:  Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoRegular,
      color: .systemGray
    )
  )
  
  private let dismissButton = UIButton.withStyle(
    f: Style.configureButtonTitle(
      image: UIImage(named: "dismiss_button")?.withTintColor(.black))
    <> Style.baseImageButtonStyle()
  )
  

  init(imageName: String) {
    super.init(nibName: nil, bundle: nil)
    label.text = imageName
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setUpLayout()
  }
  
  func setUpLayout() {
    view.addSubview(imageScrollView)
    imageScrollView.addEdgeContstraints()
    
    view.addSubview(label)
    label.addEdgeContstraints(
      exclude: .bottom,
      offset: UIEdgeInsets(top: 15, left: 10, bottom: 0, right: -10)
    )
    
    imageScrollView.addSubview(dismissButton)
    dismissButton.addEdgeContstraints(
      exclude: .bottom, .left,
      offset: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: -15)
    )
    dismissButton.addHeightWeightConstraints(values: CGPoint(x: 40, y: 40))

    dismissButton.addTarget(self, action: #selector(close), for: .touchUpInside)
  }

  func change(image: UIImage?) {
    imageScrollView.set(image: image)
  }
  
  @objc func close() {
    self.dismiss(animated: true, completion: nil)
  }

  
}

