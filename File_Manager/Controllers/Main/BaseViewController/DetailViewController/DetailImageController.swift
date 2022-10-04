//
//  DetailImageViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 09.03.2022.
//

import UIKit
import BLTNBoard

protocol HandlingDetailImageToolBar {
  func didTapDelete(at indexPath: IndexPath)
}


class DetailImageController: UIViewController {
  
  var handleToolBar: HandlingDetailImageToolBar?
  
  private lazy var imageScrollView = ImageScrollView(frame: view.bounds)
  private var indexPath: IndexPath?
  
  private var imageNameLabel = UILabel.withStyle(
    Style.baseLabelStyle <>
    Style.appearanceLabelStyle(
      withFont: Fonts.robotoRegular,
      color: .black
    )
  )
  
  private let dismissButton = UIButton.withStyle(
    Style.configureButtonTitle(
      image: UIImage(systemName: "arrow.backward")?
        .withTintColor(.black).withPointSize(30))
  )
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
    navigationController?.setToolbarHidden(true, animated: true)
    navigationController?.setToolbarItems(nil, animated: true)
    tabBarController?.tabBar.isHidden = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = false

    view.backgroundColor = Colors.baseBackground
    setVisible()
    setUpToolBar()
    setUpLayout()
    
    bindZoom()
  }
  
  func configure(title: String? = nil, indexPath: IndexPath? = nil) {
    self.title = title
    self.indexPath = indexPath
  }

  func change(image: UIImage?) {
    imageScrollView.set(image: image)
  }


  private func bindZoom() {
    imageScrollView.didStartZooming = { [weak self] in
      self?.setUnvisible()
    }
    imageScrollView.didEndZooming = { [weak self] in
      self?.setVisible()
    }
  }
  


  private func setVisible() {
    UIView.animate(withDuration: 0.15) {
      self.view.backgroundColor = Colors.baseBackground
      self.navigationController?.isToolbarHidden = false
    }
      self.navigationController?.isNavigationBarHidden = false
  }
  
  private func setUnvisible() {
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
  
  private func setUpLayout() {
    view.addSubview(imageScrollView)
    imageScrollView.addEdgeContstraints()

    view.addSubview(imageNameLabel)
    imageNameLabel.addEdgeContstraints(
      exclude: .bottom,
      offset: UIEdgeInsets(top: 15, left: 10, bottom: 0, right: -10)
    )
  }
}

// MARK: - Toolbar handle

extension DetailImageController {
  @objc func didTapSave() {
    if let image = imageScrollView.getImage {
      UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }
  }
  
  @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    let item = BLTNPageItem(title: "Successfuly saved")
    item.actionButtonTitle = "Ok"
    let manager = BLTNItemManager(rootItem: item)
    item.actionHandler = {_ in
      manager.dismissBulletin()
    }
    manager.showBulletin(above: self)
    
  }

  @objc func didTapShare(_ sender: UIButton) {
    
    if let image = imageScrollView.getImage {
      let shareSheetVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
      shareSheetVC.popoverPresentationController?.sourceView = sender
      shareSheetVC.popoverPresentationController?.sourceRect = sender.frame
      
      present(shareSheetVC, animated: true)
    }
  }
  
  @objc func didTapDelete() {
    if let indexPath = indexPath {
      handleToolBar?.didTapDelete(at: indexPath)
    }
  }
}

