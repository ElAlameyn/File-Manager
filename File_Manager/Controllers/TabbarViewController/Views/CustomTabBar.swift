//
//  CustomTabBar.swift
//  File_Manager
//
//  Created by Артем Калинкин on 04.02.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class CustomTabBar: UIStackView
{
  var itemTapped: Observable<Int> { itemTappedSubject.asObserver() }
  
  private lazy var customViews: [CustomTabItemView] = [
    CustomTabItemView(with: .home, index: 0),
    CustomTabItemView(with: .statistic, index: 1),
    CustomTabItemView(with: .storage, index: 2),
    CustomTabItemView(with: .options, index: 3)
  ]
  
  private let itemTappedSubject = PublishSubject<Int>()
  private let disposeBag = DisposeBag()
  
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

    backgroundColor = Colors.meetBlueBackground
    layer.cornerRadius = 40
    
    customViews.forEach({
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.clipsToBounds = true
    })
  }
  
  private func bind() {
    customViews.forEach({
      let index = $0.index
      $0.rx.tapGesture().when(.recognized).bind { [weak self] _ in
      self?.selectItem(at: index)
      }
      .disposed(by: disposeBag)
    })
  }
  
  private func selectItem(at index: Int) {
    customViews.forEach { $0.isSelected = $0.index == index }
    itemTappedSubject.onNext(index)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
