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
//randomIntPublisher.print().sink()
//randomIntPublisher.print().collect(100).first().sink()
//[0, 1].publisher.subscribe(IntSubscriber(demand: .unlimited))


// MARK: Publishers

var subscriptions = Set<AnyCancellable>()
let anyStrIntList: [Any] = [1, 2, 3, 4,"one", 5, 6]
enum MyError: String, Error {
    case unknown
    case timeout
}


extension Publisher where Self.Failure == Never {
    public func sinkAndPrintValue(_ name: String, printDate: Bool = false) -> AnyCancellable {
        let prefix = printDate ? "\(Date.now) " : ""
        return sink { _ in } receiveValue: { value in debugPrint("\(prefix)\(name): \(value)") }
    }
}

extension Publisher {
    public func sinkAndPrintValueOrError(_ name: String) -> AnyCancellable {
        return sink { completion in debugPrint("\(name): \(completion)") }
                receiveValue: { value in debugPrint("\(name): \(value)") }
    }
    
    public func sink() -> AnyCancellable {
        return sink { _ in } receiveValue: { _ in }
    }
}

func delayedTyping(typing: [(TimeInterval, String)], printName: String = "") -> AnyPublisher<String, Never> {
    return typing.publisher.flatMap { (delay, value) in
        return Just(value).delay(for: .seconds(delay), scheduler: DispatchQueue.main).print(printName)
    }.eraseToAnyPublisher()
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
    
    let sub1 = justP.print("Just").sink()
    let sub2 = justP.print().sink()
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
func futureFailOnValueLessThanTwo(value: Int, delay: TimeInterval = 1) -> Future<Int, MyError> {
    return Future<Int, MyError> { promise in
        print("Entered after publisher is initialized")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("Send result")
            if value > 2 {
                promise(.success(value))
            } else {
                promise(.failure(MyError.unknown))
            }
        }
    }
}

func tryFuture() {
    let future = futureFailOnValueLessThanTwo(value: 5)

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
        futureFailOnValueLessThanTwo(value: value)
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
    
    let subscription = publisher.print("Notification").sink()
    
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
    
// MARK: -Operators

/**
 #Map
        - Same as standard map just works with values emitted by a publisher
 */

/**
 #TryMap
        - Same as map but it can throw errors which will be emitted downstream
    - See dataTaskPublisher
 */

/**
 #CompactMap
        - Only publishes non-nil values
 */
//anyStrIntList.publisher.compactMap { $0 as? Int }.sinkAndPrintValue("CompactMap")

/**
 #TryCompactMap
        - ame as  compactMap with the possibility of error throwing/failing pipeline
 */

/**
 #FlatMap
        - Replaces the incoming values with a new publisher
    - flatMap(maxPublishers: ...) it can also specify the maximum number of concurrent publisher subscriptions
      i.e. .max(1) will create a serial publisher  .unlimited creates an unbounded concurrent publisher
    #Usage:
        - Pass elements returned by a publisher to a new method that creates a new publisher and subscribe to the results emitted by the second publisher only
        - e.g. create concurrent data tasks from a list of urls
 */

func tryFlatMapWithError(){
    let futureIntsWithFail = [1, 2, 3, 4, 5]
    
    
    // publishers with error thrown i.e. the whole pipeline is finished and the rest of them after the fail won't be started
    futureIntsWithFail.publisher
        .flatMap { futureFailOnValueLessThanTwo(value: $0, delay: TimeInterval($0)) }
        .sinkAndPrintValueOrError("Flatmap With error")
        .store(in: &subscriptions)
}

func tryFlatMapWithNoError() {
    let futureIntsNoFail = [3, 4, 5]
    // Serial publisher creation
    futureIntsNoFail.publisher
                    .flatMap(maxPublishers: .max(1)) { futureFailOnValueLessThanTwo(value: $0, delay: TimeInterval($0)) }
                    .sinkAndPrintValueOrError("Flatmap Max 1")
                    .store(in: &subscriptions)
    
    // All publihsers started concurrently and waits for all of them to finish before emitting the result
    // Wait for all of them to be finished
    futureIntsNoFail.publisher
                    .flatMap { futureFailOnValueLessThanTwo(value: $0, delay: TimeInterval($0)) }
                    .collect()
                    .sinkAndPrintValueOrError("Flatmap and collect")
                    .store(in: &subscriptions)
}

//tryFlatMapWithError()
//tryFlatMapWithNoError()

/**
 #SetFailureType
        - Does not send a failure it just changes the failure type to the specified type e.g. Transform Never error types to a new error type to match the type info with other publishers
 */
func provideValueOrFail(_ value: Int?) -> AnyPublisher<Int, MyError> {
    guard let value else {
        return Fail(error: MyError.unknown).eraseToAnyPublisher()
    }
    return Just(value)
        .setFailureType(to: MyError.self)
        .eraseToAnyPublisher()
}

//let p = provideValueOrFail(5)
//p.sinkAndPrintValueOrError("SetFailure")


/**
 #ReplaceNil(with: ...)
        - Replaces the nil elements from the stream with a default element
    #Usage
        - Specify a placeholder for nil values,
 */

/**
 #ReplaceError(with: ...)
        - Catches the error provided by the upstream publisher and replaces it with a default value
    - The stream will still complete/finish even if we replace the error
    #Usage
        - If we don't care about the error that was emitted and just want to provide a default return value when an error is thrown
 */

/**
 #ReplaceEmpty(with: ...)
        - Return a value when a publisher finishes without emitting any values e.g. Empty publisher
    - It will only return a value if the publisher receives a finished completion before it produces any values
    #Usage
        - When we want the stream to always provide a value even if the upstream publishers do not provide one
 */

//Empty<Int, Never>().replaceEmpty(with: 100_000).print("ReplaceEmpty").sink()

//Empty<Int, Never>(completeImmediately: false).replaceEmpty(with: 100_000).print("ReplaceEmptyWithoutFinish").sink()


/**
 #Scan(acc, current)
        - Emits the accumulated values and the current values and return a publisher the emits these accumulations over time
    - Similar to reduce, but while reduce emits only the result of all of the accumulated values scan provides the intermediate results as well
 */

func tryScan() {
    [1,2,3,4,5].publisher
               .scan(0, +)
               .sinkAndPrintValue("Scan")
}


/**
 #TryScan(acc, current)
        - Similar to scan but we can throw an error from it as well
 */
func tryFailableScan() {
    anyStrIntList.publisher
                 .tryScan(0) {
                     guard let value = $1 as? Int else { throw MyError.unknown }
                     return $0 + value
                 }.sinkAndPrintValueOrError("TryScan")
}

/**
 #Filter(condition)
        - It will only republish the value that it got if the condition is satisfied for this value otherwise it just drops it
 */

/**
 #TryFilter(condition)
        - Same as filter with the option to throw an error and fail the filtering
 */

func tryFailableFilter() {
    anyStrIntList.publisher
                 .tryFilter {
                     guard let value = $0 as? Int else {
                         throw MyError.unknown
                     }
                     return value > 3
                 }.sinkAndPrintValueOrError("Try filter")
}

/**
 #RemoveDuplicates
        - Automatically works for any values that conform to Equatable
    - If the values are not Equatable we can provide custom implementation for equality check through a closure
    - !!! Only checks the previously sent value and the current value, if we have reucurring values that are not going to be published sequentially they won't be removed
 */

func tryRemoveDuplicates() {
    [1, 2, 2, 1, 3, 4, 3, 2].publisher
                            .removeDuplicates()
                            .sinkAndPrintValue("Remove Duplicates")
}

/**
 #TryRemoveDuplicates
        - Same as removeDuplicates with the possibility of error throwing/failing pipeline
 */



/**
 #Collect
        - Collects the received elements and provides them in a single array.
    - !!! uses unbounded amount of memory to buffer values
    - It can collect by count
        - unlimited, collects all received values into one Array until the publisher finishes
        - by count, collects all received values into multiple Arrays containing count number of values until the publisher finishes
    - Time and count strategy
        - byTime: emits a value at each interval
        - byTimeOrCount:
            - specifies the scheduler on which to operate and time interval stride over which to run, collects all values that it received from the upstream during this time
            - collects both by time and count i.e.
 */
func tryCollect() {
    let publisher = [1, 2, 3, 4, 5].publisher
    //publisher.collect().print().sinkAndPrintValue("Collect")
    //publisher.collect(3).sinkAndPrintValue("Collect 3")
    
    let emitZeroEverySecond = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().map { _ in 0 }
    emitZeroEverySecond.sinkAndPrintValue("\(Date.now) Timer")
                       .store(in: &subscriptions)
    emitZeroEverySecond
        .collect(.byTimeOrCount(DispatchQueue.global(), .seconds(5), 2))
        .sinkAndPrintValue("Collect timeOrCount")
        .store(in: &subscriptions)
}

//tryCollect()

/**
 #IgnoreOutput
        - Drops all values that were published and only passes along the completion result
    #Usage
        - if we only care if the stream has finished or failed
 */


/**
 #Reduce(acc, current)
        - return a publisher the emits these accumulated result of all the values in the stream and a default value
    - It doesn't provide partial result after each publisher values as scan does
 */


func tryReduce() {
    ["Hello", "World"].publisher
                      .map { $0.count }
                      .scan(0, +)
                      .reduce(0, +)
                      .sinkAndPrintValue("Scan & reduce with str lenght")
}

/**
 #TryReduce(acc, current)
        - same as reduce but can throw an error and result in the failure of this publisher
 */


// Count/Max/Min variants
/**
 #Max
 #TryMax
 #Min
 #TryMin
 #Count
 */


// First/Last variants
/**
 #First
 #Last
 #TryLastWhere
 #First(where: )
 #Last(where: )
 */

/**
 #First(where: )
        - Provides the first value that satisfies the condition
    - Once the condition is satisfied it automatically cancels the subscription and completes
 */
func tryFirstWhere() {
    [1, 2, 3, 4].publisher.print("numbers").first { $0 == 2 }.sinkAndPrintValue("First Value")
}

/**
 #Last(where: )
        - Provides the last value that satisfies the condition
    - !!! The publisher that we use this on must complete for this operator to work
 */


// Basic drop
/**
 #DropFirst(count)
 #Drop(while: {condition is met}
 #TryDrop(while: {condition is met}
 */
/**
 #Drop(untilOutputFrom: triggerPublisher)
        - Drops any values emitted by a publisher until a second publisher starts emitting values
 */
func tryDropUntilOutputFrom() {
    let firstPublisher = PassthroughSubject<Void, Never>()
    let secondPublisher = PassthroughSubject<Int, Never>()

    secondPublisher.drop(untilOutputFrom: firstPublisher)
                   .sinkAndPrintValue("Drop until output")
                   .store(in: &subscriptions)

    secondPublisher.send(1)
    secondPublisher.send(2)
    secondPublisher.send(3)

    firstPublisher.send()

    secondPublisher.send(5)
    secondPublisher.send(6)
}



/**
 #Prefix(count)
        - Receive "count" number of values then terminates the publisher afterwards
 */

/**
 #Prefix(while condition is met)
        - Receive values  while the condition is met then terminates the publisher afterwards
 */

/**
 #Prefix(untilOutputFrom: triggerPublisher)
        - Sends values emitted by the publisher until a second publisher starts emitting values at which point it terminates the publisher
 */

func tryPrefix() {
//    [0, 1, 2, 3].publisher.print("Publisher").prefix { $0 < 2 }.print("Prefix").sink()
    
    let firstPublisher = PassthroughSubject<Void, Never>()
    let secondPublisher = PassthroughSubject<Int, Never>()

    secondPublisher.prefix(untilOutputFrom: firstPublisher)
                   .print("Prefix until output")
                   .sink()
                   .store(in: &subscriptions)

    secondPublisher.send(1)
    secondPublisher.send(2)
    secondPublisher.send(3)

    firstPublisher.send()

    secondPublisher.send(5)
    secondPublisher.send(6)
}

//tryPrefix()

/**
 #Prepend(values)
 #Prepend(sequence)
 */

/**
 #Prepend(publisher)
        - publisher1.prepend(publisher2)
    - publisher2 must finish before publisher1 can continue to receive values
 */

func tryPrepend() {
    let firstPublisher = PassthroughSubject<Int, Never>()
    let secondPublisher = PassthroughSubject<Int, Never>()

    secondPublisher.prepend(firstPublisher)
                   .print("Prepend")
                   .sink()
                   .store(in: &subscriptions)

    secondPublisher.prepend([-1, -1])
                   .print("Prepend value")
                   .sink()
                   .store(in: &subscriptions)
    
    secondPublisher.send(1)
    secondPublisher.send(2)
    secondPublisher.send(3)

    firstPublisher.send(-1)
    firstPublisher.send(-2)
    firstPublisher.send(-3)
    
    // if we don't finish the prepended publisher we won't know what we'll prepend to
    firstPublisher.send(completion: .finished)

    secondPublisher.send(4)
    secondPublisher.send(5)
}

//tryPrepend()

/**
 #Append(values)
 #Append(sequence)
 */

/**
 #Append(publisher)
        - publisher1.append(publisher2)
    - publisher1 must finish before publisher2 can continue to receive values
 */

func tryAppend() {
    let firstPublisher = PassthroughSubject<Int, Never>()
    let secondPublisher = PassthroughSubject<Int, Never>()

    firstPublisher.append(secondPublisher)
                  .print("Append")
                  .sink()
                  .store(in: &subscriptions)
    
    secondPublisher.send(1)
    secondPublisher.send(2)
    secondPublisher.send(3)

    firstPublisher.send(-1)
    firstPublisher.send(-2)
    firstPublisher.send(-3)
    
    // if we don't finish the prepended publisher we won't know what we'll prepend to
    firstPublisher.send(completion: .finished)

    secondPublisher.send(4)
    secondPublisher.send(5)
}

//tryAppend()

/**
 #SwitchToLatest
    - Flattens any nested publisher types and provides the most recent publisher only and cancels all previous publishers
    #Usage
        - prevents earlier publishers to do unncessary work
        - e.g. network requests from frequent user interface publishers, continuous refreshes that create API calls
 */

func trySwitchToLatest() {
    let s1 = PassthroughSubject<Int, Never>()
    let s2 = PassthroughSubject<Int, Never>()

    let subjects = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()

    subjects
        .switchToLatest()
        .sinkAndPrintValue("SwitchToLatest")

    subjects.send(s1)
    s1.send(1)
    subjects.send(s2)
    s1.send(2)
    s2.send(3)
    subjects.send(s1)
    s1.send(2)
}

//trySwitchToLatest()


/**
 #Merge
    - accepts 2 upstream publishers and mixes the elements received from both as they are received.
  - if the two publishers are sending the values at the same time they will be merged in the same order as the publishers were defined in.
  - we also have merge3, merge4...merge8
  - the output and input types of the merge publishers must match.
  - If one of the publishers finishes normally the merged publisher continues receiving values from the unfinished one, if one of the finishes with a failure we don't receive
    any more updates from the unfinished one either
  - can be used with more than 2 publishers
 */

func tryMergeWithFinishCompletion() {
    let s1 = PassthroughSubject<Int, MyError>()
    let s2 = PassthroughSubject<Int, MyError>()

    s1.merge(with: s2)
      .sinkAndPrintValueOrError("Merge with S1 finish")

    s1.send(1)
    s1.send(2)
    s2.send(-1)
    s1.send(3)
    
    debugPrint("Finish S1")
    s1.send(completion: .finished)
    
    s1.send(4)
    s2.send(-5)
}

func tryMergeWithErrorCompletion() {
    let s1 = PassthroughSubject<Int, MyError>()
    let s2 = PassthroughSubject<Int, MyError>()

    s1.merge(with: s2).print()
      .sinkAndPrintValueOrError("Merge With S1 error")

    s1.send(1)
    s1.send(2)
    s2.send(-1)
    s1.send(3)
    
    debugPrint("Fail S1")
    s1.send(completion: .failure(.unknown))
    
    s1.send(4)
    s2.send(-5)
}

//tryMergeWithFinishCompletion()
//tryMergeWithErrorCompletion()


/**
 #CombineLatest
    - accepts 2 upstream publishers and combines the results from them by providing a tuple with the latest values from all publishers whenever one of them publishes a new value
  - it can merge publishers with different output types, but the failure type must match
  - !!! the original publisher and every publisher that is combined with combineLatest has to emit at least one value from the combined publishers to start emitting value, this also means that we might
     miss emitted values from one publisher if it is received before all the combined publishers sent out at least one value
  - if one of the combined publisher completed without error the other publishers can still emit values and will combine the results with the last emitted value from the finished publisher
  - if one of the publishers completed with an error the whole pipeline completes with an error and stops emitting values
 */


func tryCombineLatestWithErrorCompletion() {
    let s1 = PassthroughSubject<Int, MyError>()
    let s2 = PassthroughSubject<Int, MyError>()

    s1.combineLatest(s2, s2)
      .sinkAndPrintValueOrError("CombineLatest with error")

    s1.send(1)
    s1.send(2)
    s2.send(-2)
    s1.send(3)
    
    debugPrint("Fail S1")
    s1.send(completion: .failure(.unknown))
    
    s2.send(-3)
    s1.send(4)
}

func tryCombineLatestWithFinishedCompletion() {
    let s1 = PassthroughSubject<Int, MyError>()
    let s2 = PassthroughSubject<Int, MyError>()

    s1.combineLatest(s2, s2)
      .sinkAndPrintValueOrError("CombineLatest with finish")

    s1.send(1)
    s1.send(2)
    s2.send(-2)
    s1.send(3)
    
    debugPrint("Finish S1")
    s1.send(completion: .finished)
    
    s2.send(-3)
    s1.send(4)
    s2.send(-4)
    s2.send(-5)
}

//tryCombineLatestWithErrorCompletion()

/**
 #Zip
    - accepts 2 or more upstream publishers and waits until a new value is sent from all the publishers before emitting a new tuple (so it doesn't use the latest value)
  - it can merge publishers with different output types, but the failure type must match
  - !!! the original publisher and every publisher that is combined with zip has to emit one value from the combined publishers to start emitting value, this also means that we might
     miss emitted values from one publisher if it is received before all the combined publishers sent out at least one value
  - if one of the combined publisher completed without error the the combined publisher will also finish after all emitted values were zipped
  - if one of the publishers completed with an error the whole pipeline completes with an error and stops emitting values
    #Usage
    - synchronize results from multiple async calls
 */


func tryZipWithErrorCompletion() {
    let s1 = PassthroughSubject<Int, MyError>()
    let s2 = PassthroughSubject<Int, MyError>()

    s1.zip(s2)
      .sinkAndPrintValueOrError("Zip with error")

    s1.send(1)
    s1.send(2)
    s2.send(-2)
    s1.send(3)
    
    debugPrint("Fail S1")
    s1.send(completion: .failure(.unknown))
    
    s2.send(-3)
    s1.send(4)
}

// Note: even though we send the completion to s1 after it emitted 3 values, since s2 only emitted 2 the completion of the pipeline will only happen
// when s2 also emits 3 values
func tryZipWithFinishedCompletion() {
    let s1 = PassthroughSubject<Int, MyError>()
    let s2 = PassthroughSubject<Int, MyError>()

    s1.zip(s2)
      .sinkAndPrintValueOrError("Zip with finish")

    s1.send(1)
    s1.send(2)
    s2.send(-1)
    s1.send(3)
    
    debugPrint("Finish S1")
    s1.send(completion: .finished)
    
    s2.send(-2)
    s1.send(4)
    s2.send(-3)
//    s2.send(-4)
//    s2.send(-5)
}

//tryZipWithErrorCompletion()
//tryZipWithFinishedCompletion()


/**
 #Delay
 - delays delivery of the output
 */

func tryDelay() {
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    timer.sinkAndPrintValue("\(Date.now) Timer")
         .store(in: &subscriptions)
    
    timer.delay(for: 2, scheduler: DispatchQueue.main)
         .sinkAndPrintValue("\(Date.now) Delayed")
         .store(in: &subscriptions)
}
//tryDelay()

/**
 #Debounce
 - delays delivery of the output
 - only publishes a value when x amount of time has passed from publishing the last value
 - if the publisher completes before the time configured in the debounce elapses from the time the last value was emitted we will never receive this value
  #Usage
    - only process events if x amount of time has passed since the last emitting
 */

func tryDebounce() {
    let typingHelloWorld: [(TimeInterval, String)] = [
      (0.0, "H"),
      (0.1, "He"),      // + 0.1
      (0.2, "Hel"),     // + 0.1
      (0.3, "Hell"),    // + 0.1
      (0.5, "Hello"),   // + 0.2
      (0.6, "Hello "), // + 0.1
      (2.0, "Hello W"), // + 1.6
      (2.1, "Hello Wo"),
      (2.2, "Hello Wor"),
      (2.4, "Hello Worl"), // won't be emmitted since the publisher completes before the delay has passed
    ]

    let delayedTyping = typingHelloWorld.publisher.flatMap { (delay, value) in
        return Just(value).delay(for: .seconds(delay), scheduler: DispatchQueue.main).print()
    }
    
    delayedTyping.debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sinkAndPrintValue("Debounce")
            .store(in: &subscriptions)
}

//tryDebounce()


/**
 #Throttle
 - similar to debounce in the fact that it waits to emit results
 - debounce waits for a pause in values that it receives and emits the latest one after encountering a pause as long as the specified interval
 - throttle waits for the specified interval then emits the first or last value that was emitted during that interval and it doesn't care about the pauses
 */
func tryThrottle() {
    let typingHelloWorld: [(TimeInterval, String)] = [
      (0.0, "H"),
      (0.1, "He"),
      (0.2, "Hel"),
      (0.3, "Hell"),
      (0.5, "Hello"),
      (0.6, "Hello "),
      (2.0, "Hello W"),
      (2.1, "Hello Wo"),
      (2.2, "Hello Wor"),
      (2.4, "Hello Worl"),
      (5.3, "Hello World"),
    ]

    let delayedTyping = delayedTyping(typing: typingHelloWorld, printName: "Type")
    
    delayedTyping.throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sinkAndPrintValue("Throttle")
            .store(in: &subscriptions)
}

//tryThrottle()


/**
 #TimeOut
 - terminates the publisher if no values have been received under the specified timeout
 */

func tryTimeout() {
    let typingHelloWorld: [(TimeInterval, String)] = [
      (2.0, "H"),
      (2.5, "He"),
    ]
    
    let typingHolaAfter5Sec: [(TimeInterval, String)] = [
      (5.0, "H"),
      (5.5, "Ho"),
    ]

    let delayed2SecTyping = delayedTyping(typing: typingHelloWorld, printName: "2sec Type")
    delayed2SecTyping.timeout(5, scheduler: DispatchQueue.main)
                    .sinkAndPrintValue("Timeout")
                    .store(in: &subscriptions)
    
    let delayed5SecTyping = delayedTyping(typing: typingHolaAfter5Sec, printName: "5sec Type")
    
    delayed5SecTyping.timeout(5, scheduler: DispatchQueue.main)
                     .sinkAndPrintValue("Timeout")
                     .store(in: &subscriptions)
}
tryTimeout()
