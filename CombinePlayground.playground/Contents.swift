//
//  APIClient.swift
//  Starter Project
//
//  Created by Evelyne Suto on 12.01.2023.
//

import Foundation
import Combine

// Custom Publisher: https://thoughtbot.com/blog/lets-build-a-custom-publisher-in-combine
// Substom Subscriber: https://jllnmercier.medium.com/combine-creating-a-custom-subscriber-c1db12c2721
struct RandomIntPublisher: Publisher {
    typealias Output = Int
    typealias Failure = Never
    
    let randRange: Range<Output>
    
    public init(_ range: Range<Output>) {
        self.randRange = range
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Int == S.Input {
        debugPrint("Publisher received subscriber: \(subscriber)")
        subscriber.receive(subscription: MySubscription(range: randRange, subscriber: subscriber))
    }
}

extension RandomIntPublisher {
    private class MySubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        var combineIdentifier: CombineIdentifier = CombineIdentifier()
        
        private var subscriber: S?
        private let randRange: Range<Output>
        
        fileprivate init(range: Range<Int>, subscriber: S) {
            self.randRange = range
            self.subscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            debugPrint("Subscription demand received: \(demand)")
            guard demand > 0 else { return }
            var demand = demand
            while let subscriber = subscriber, demand > 0 {
                demand -= 1
                let randInt = Int.random(in: randRange)
                let newDemand = subscriber.receive(randInt)
                demand += newDemand
            }
            
            subscriber?.receive(completion: .finished)
            cancel()
        }
        
        func cancel() {
            subscriber = nil
        }
    }
}

struct IntSubscriber: Subscriber {
    var combineIdentifier: CombineIdentifier = CombineIdentifier()
    
    typealias Input = Int
    typealias Failure = Never
    
    private var demand: Subscribers.Demand
    init(demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    // Triggered once when the publisher is bound to the subscriber
    func receive(subscription: Subscription) {
        subscription.request(demand)
    }
    
    // Received every time a new value is delivered. We can recalculate the demand based on the received value.
    func receive(_ input: Input) -> Subscribers.Demand {
        debugPrint("Subscriber received input: \(input)")
        return .none
    }
    
    // Triggered when the stream doesn't have any more data
    func receive(completion: Subscribers.Completion<Failure>) {
        debugPrint("Subscriber Completed: \(completion)")
    }
}


let randomIntPublisher = RandomIntPublisher(0..<100)

/// !!! Unlimited stream
// randomIntPublisher.print().subscribe(IntSubscriber(demand: .unlimited))
// randomIntPublisher.print().subscribe(on: DispatchQueue.global()).subscribe(IntSubscriber(demand: .unlimited))
//
//randomIntPublisher.subscribe(IntSubscriber(demand: .none))
//
//randomIntPublisher.first().subscribe(IntSubscriber(demand: .unlimited))
//
//Just(1).first().subscribe(IntSubscriber(demand: .unlimited))
//
//randomIntPublisher.subscribe(IntSubscriber(demand: .max(3)))
//
//randomIntPublisher.filter { $0 < 5 }.subscribe(IntSubscriber(demand: .max(3)))
//
//randomIntPublisher.print().sink{ _ in }


randomIntPublisher.print().collect(100).first().sink { _ in }
[0, 1].publisher.subscribe(IntSubscriber(demand: .unlimited))
