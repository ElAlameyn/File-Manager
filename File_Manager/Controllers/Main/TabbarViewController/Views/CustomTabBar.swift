//
//  CustomTabBar.swift
//  File_Manager
//
//  Created by Артем Калинкин on 04.02.2022.
//

import UIKit
import Combine

class CustomTabBar: UIStackView {
  var itemTapped = PassthroughSubject<Int, Never>()
  private var cancellables: Set<AnyCancellable> = []

  private lazy var customViews: [CustomTabItemView] = [
    CustomTabItemView(with: .home, index: 0),
    CustomTabItemView(with: .statistic, index: 1),
    CustomTabItemView(with: .storage, index: 2)
  ]
  
  init() {
    super.init(frame: CGRect.zero)

    bind()
    setUpUI()
    setNeedsLayout()
    layoutIfNeeded()
    selectItem(at: 0)
  }

  private func setUpUI() {
    customViews.forEach { addArrangedSubview($0) }

    distribution = .fillEqually
    alignment = .center

    backgroundColor = Colors.tabBarBackground
    layer.cornerRadius = 40
    
  }

  func bind() {
    customViews.forEach({ view in
      view.translatesAutoresizingMaskIntoConstraints = false
      let gesture = UITapGestureRecognizer(target: self, action: nil)
      view.publisher(for: gesture).sink { [weak self] _ in
        self?.selectItem(at: view.index)
      }.store(in: &cancellables)
    })
  }

  private func selectItem(at index: Int) {
    customViews.forEach { $0.isSelected = $0.index == index }
    itemTapped.send(index)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
