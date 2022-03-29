//
//  DetailImageViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 09.03.2022.
//

import UIKit

class DetailImageController: UIViewController {
  
  private lazy var imageScrollView = ImageScrollView(frame: view.bounds)
  
  private var imageNameLabel = UILabel.withStyle(
  f:  Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoRegular,
      color: .black
    )
  )
  
  private let dismissButton = UIButton.withStyle(
    f: Style.configureButtonTitle(
      image: UIImage(systemName: "arrow.backward")?
        .withTintColor(.black).withPointSize(30))
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.baseBackground
    setUpToolBar()
    setUpLayout()
    
    imageScrollView.didStartZooming = { [weak self] in
      self?.setUnvisible()
    }
    imageScrollView.didEndZooming = { [weak self] in
      self?.setVisible()
    }
  }
  
  fileprivate func setVisible() {
    UIView.animate(withDuration: 0.15) {
      self.view.backgroundColor = Colors.baseBackground
      self.navigationController?.isToolbarHidden = false
    }
      self.navigationController?.isNavigationBarHidden = false
  }
  
  @objc func setUnvisible() {
    UIView.animate(withDuration: 0.15) {
      self.view.backgroundColor = .black
      self.navigationController?.isToolbarHidden = true
    }
      self.navigationController?.isNavigationBarHidden = true
  }

  
  private func setUpToolBar() {
    navigationController?.isToolbarHidden = false
    navigationController?.toolbar.tintColor = .black
    navigationController?.toolbar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    toolbarItems = [
      UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete)),
      .flexibleSpace(),
      UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(didTapSave)),
      .flexibleSpace(),
      UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
    ]
  }
  
  @objc func didTapSave() {
    // TODO: Add save logic
  }

  @objc func didTapShare() {
    // TODO: Add share logic
  }
  @objc func didTapDelete() {
    // TODO: Add delete logic
  }
  
  private func setUpLayout() {
    view.addSubview(imageScrollView)
    imageScrollView.addEdgeContstraints()

    view.addSubview(imageNameLabel)
    imageNameLabel.addEdgeContstraints(
      exclude: .bottom,
      offset: UIEdgeInsets(top: 15, left: 10, bottom: 0, right: -10)
    )
  }

  func change(image: UIImage?) {
    imageScrollView.set(image: image)
  }
}

