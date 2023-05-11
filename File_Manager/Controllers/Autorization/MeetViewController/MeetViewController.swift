//
//  ViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 27.01.2022.
//

import Combine
import UIKit

class MeetViewController: UIViewController {
  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
  }

  @objc func submitButtonTapped() {
    // TODO: Add alert contoller
    let authVC = AuthViewController()
    authVC.modalTransitionStyle = .crossDissolve
    authVC.modalPresentationStyle = .fullScreen
    guard let checkRequest = RequestConfigurator.check.setRequest() else { return }
    subscriber = URLSession.shared.dataTaskPublisher(for: checkRequest)
      .receive(on: DispatchQueue.main)
      .tryMap { [weak self] _, response in
        guard let self else { return }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 401 {
          navigationController?.pushViewController(TabBarViewController(), animated: true)
        } else {
          print("Access token expired")
          navigationController?.present(authVC, animated: true)
          authVC.dismissed = { [weak self] in
            authVC.dismiss(animated: true)
            self?.navigationController?.pushViewController(TabBarViewController(), animated: true)
          }
        }
      }
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
  }

  // MARK: Private

  private var subscriber: AnyCancellable?

  private func setUpUI() {
    view.backgroundColor = Colors.meetBlueBackground
    addBlueLock()
    addMeetView()
  }

  private func addMeetView() {
    let meetView = MeetView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 300)))
    view.addSubview(meetView)

    meetView.addCenterConstraints(exclude: .axisY)
    meetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -92).isActive = true
    meetView.addHeightWeightConstraints(values: CGPoint(x: 300, y: 300))
  }

  private func addBlueLock() {
    let imageView = UIImageView(image: Images.blueLock)
    view.addSubview(imageView)

    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.addCenterConstraints()
    imageView.addHeightWeightConstraints(values: CGPoint(x: 800, y: 800))
  }
}
