//
//  CustomPublisher.swift
//  Starter Project
//
//  Created by Evelyne Suto on 13.01.2023.
//

import Combine
import Foundation
import UIKit

extension UIButton {
    var tapPublisher: UIControlPublisher {
        .init(control: self, event: .touchUpInside)
    }
}

struct UIControlPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    private var control: UIControl
    private var event: UIControl.Event
    
    init(control: UIControl, event: UIControl.Event) {
        self.control = control
        self.event = event
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        let subscription = ControlSubscription(control: control, event: event, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension UIControlPublisher {
    private class ControlSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        var combineIdentifier: CombineIdentifier = CombineIdentifier()
        private var subscriber: S?
        private let control: UIControl
        private var event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event, subscriber: S) {
            self.control = control
            self.event = event
            self.subscriber = subscriber
            
            control.addTarget(self, action: #selector(onEvent), for: event)
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
        }
        
        @objc private func onEvent() {
            _ = subscriber?.receive(())
        }
    }
}
