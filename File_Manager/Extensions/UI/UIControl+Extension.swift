//
//  UIControl+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.04.2022.
//

import UIKit
import Combine

extension UIControl {
  func publisher(for event: Event) -> EventPublisher {
    EventPublisher(control: self, event: event)
  }
}


extension UIControl {

  struct EventPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    fileprivate var control: UIControl
    fileprivate var event: Event
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Void == S.Input {
      let subscription = EventSubscription<S>()
      subscription.target = subscriber
      subscriber.receive(subscription: subscription)
      
      control.addTarget(subscription, action: #selector(subscription.trigger), for: event)
    }
    
  }
}

extension UIControl {
  class EventSubscription<Target: Subscriber>: Subscription where Target.Input == Void {
    var target: Target?
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
      target = nil
    }
    
    @objc func trigger() {
      _ = target?.receive(())
    }
  }
}
