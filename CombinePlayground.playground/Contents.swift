//
//  APIClient.swift
//  Starter Project
//
//  Created by Evelyne Suto on 12.01.2023.
//

import Foundation
import Combine

// MARK: Custom publisher + Examples
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


//let randomIntPublisher = RandomIntPublisher(0..<100)
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
//randomIntPublisher.print().collect(100).first().sink { _ in }
//[0, 1].publisher.subscribe(IntSubscriber(demand: .unlimited))


// MARK: Publishers

var subscriptions = Set<AnyCancellable>()
enum MyError: Error {
    case unknown
}

// MARK: - Just
/**
    #Just
    - Provides a single result.
    - Can't fail, error type is Never
    - Once the result has been provided it terminates
 
    #Usage
    - To return default value when catching an error. See failingDataTaskWithDefaultValue()
    - Start a chain of events. See failingDataTaskNoDefaultValue()
    
 **/
func justPublisher() {
    let justP = Just("Hello")
    
    let sub1 = justP.print("Just").sink { _ in }
    let sub2 = justP.print().sink { _ in }
}

//justPublisher()


// MARK: - Future
/**
    #Future
    - Initialized with a closure that provides a single value or a failure
    - Result is of type promise which can generate failure/success
    - The provided closure will be run at the time of creation not when a demand is received
    - e.g. promise(.failure(err))
         promise(.success(done))
    #Usage
    - To wrap asyn calls that don't have publisher support yet
    -
 **/
func future(value: Int) -> Future<Int, MyError> {
    return Future<Int, MyError> { promise in
        print("Entered after publisher is initialized")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Send result")
            if value > 2 {
                promise(.success(value + 1))
            } else {
                promise(.failure(MyError.unknown))
            }
        }
    }
}

func tryFuture() {
    let future = future(value: 5)

    // Subscriber after 5 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        future
            .print("Future")
            .sink(receiveCompletion: { _ in print("Completion") }, receiveValue: { _ in print("Received") })
            .store(in: &subscriptions)
    }
}

//tryFuture()

// MARK: - Deferred
/**
    #Deferred
    - Deferres creation of the provided publisher until someone subscribes to it
    #Usage
    - Useful when creating the publisher would be expensive
    - Defer closures provided to Future until it has a subscriber
 **/
func deferP(value: Int) -> AnyPublisher<Int, MyError> {
    return Deferred {
        future(value: value)
    }.eraseToAnyPublisher()
}

// It will only provide output after 5 seconds once we subscribe to it
func tryDefer() {
    let deferred = deferP(value: 5)

    // Subscriber after 5 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        deferred
            .print("Defer")
            .sink(receiveCompletion: { _ in print("Completion") }, receiveValue: { _ in print("Received") })
            .store(in: &subscriptions)
    }
}

//tryDefer()

// MARK: - Fail
/**
    #Fail
    - immediately terminates publishing with the specified failure.
    #Usage
    - Error handling scenarios where we need to return a publisher
 **/
func failNilValues(_ value: Int?) -> AnyPublisher<Int, MyError> {
    guard let _ = value else {
        return Fail(error: MyError.unknown).eraseToAnyPublisher()
    }
    return Empty<Int, MyError>().eraseToAnyPublisher()
}

func tryFail() {
    let fail = failNilValues(nil)
    let noFail = failNilValues(5)
    
    fail.print("Fail").sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    noFail.print("NoFail").sink(receiveCompletion: { _ in }, receiveValue: { _ in })
}

//tryFail()


// MARK: - @Published
/**
    #@Published
    - Property wrapper
    - Automatically creates a publisher for the property with Failure type Never.
    - The publisher can be accessed through the projected value with $property
    - !!! Currently they can only be used withing reference types i.e. classes
    #Usage
    - Heavily used by SwiftUI together with ObservableObject which will trigger the objectWillChange publisher to emit values every time any of the @Published properties has changed on this object
 **/



// MARK: - Built in publishers


// MARK: - NotificationCenter
func notification() {
    let notification = Notification.Name("Hello")
    let notification2 = Notification.Name("Hello2")
    let publisher = NotificationCenter.default.publisher(for: notification)
    
    let subscription = publisher.print("Notification").sink { _ in }
    
    NotificationCenter.default.post(Notification(name: notification2))
    NotificationCenter.default.post(Notification(name: notification2))
    NotificationCenter.default.post(Notification(name: notification))
}

//notification()


// MARK: - URLSession dataTaskPublisher
func failingDataTaskWithDefaultValue() -> AnyPublisher<String, Never> {
    return URLSession.shared.dataTaskPublisher(for: URL(string: "https://a.com")!)
        .tryMap{ data, response in
            guard !data.isEmpty else {
                throw MyError.unknown
            }
            return "Data Task: Have a response"
        }
        .catch { _ in Just("Data Task: Fallback Error result") }
        .eraseToAnyPublisher()
}

func failingDataTaskNoDefaultValue() -> AnyPublisher<String, MyError> {
    return Just(URL(string: "https://www.google.com")!)
            .flatMap { url in URLSession.shared.dataTaskPublisher(for: url) }
            .tryMap { data, _ in
                throw MyError.unknown
            }
            .mapError{ _ in MyError.unknown }
            .eraseToAnyPublisher()
}

func dataTask() {
    failingDataTaskWithDefaultValue().sink { result in
            switch result {
            case .finished:
                print("Data Task: Finished")
            case .failure:
                print("Data Task: Fail")
            }
        } receiveValue: { v in
            print("Data Task: Received \(v)")
        }.store(in: &subscriptions)
    
    failingDataTaskNoDefaultValue()
        .sink { result in
            switch result {
            case .finished:
                print("Data Task2: Finished")
            case .failure:
                print("Data Task2: Fail")
            }
        } receiveValue: { v in
            print("Data Task2: Received \(v)")
        }.store(in: &subscriptions)
}

//dataTask()

// MARK: - MakeConnectable
/**
    #.makeConnectable() -> Creates a ConnectablePublisher with connect() & autoconnect() functionality
    - A connectable publisher will only start it's stream once we have explicitly called the connect()/autoconnect() on them
    - autoconnect() <-> automatically connects when the first subscriber has subscribed i.e. it behaves as a non-connectable publisher
    #Usage
    - Coordinate the timing of connecting multiple subscribers to the same publishers
 **/
// MARK: - Timer
/**
    Timer is a Connectable publisher. When we want to start receiving values from it we must call the connect() method on it first
 */

func tryAutoconnectTimer() {
    let timer = Timer.publish(every: 1.0, on: RunLoop.main, in: .common)
        .autoconnect()
    
    timer.sink { receivedTimeStamp in
        print("passed through: ", receivedTimeStamp)
    }
    .store(in: &subscriptions)
}

func tryNonAutoconnectTimer() {
    let timer = Timer.publish(every: 1.0, on: RunLoop.main, in: .common)
    
    timer.sink { receivedTimeStamp in
        print("passed through: ", receivedTimeStamp)
    }
    .store(in: &subscriptions)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        timer.connect().store(in: &subscriptions)
    }
}

// tryAutoconnectTimer()
//tryNonAutoconnectTimer()
    
