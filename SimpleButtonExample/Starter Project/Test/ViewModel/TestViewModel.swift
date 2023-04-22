//
//  TestViewModel.swift
//  Starter Project
//
//  Created by Evelyne Suto on 13.01.2023.
//

import Combine
import Foundation

class TestViewModel {
    let currentValue = CurrentValueSubject<Int, Never>(0)
    func increase() {
        currentValue.send(currentValue.value + 1)
    }
    
    func decrease() {
        currentValue.send(currentValue.value - 1)
    }
}

//import RxSwift
//class RxExamplesViewModel {
//    enum MyError: Error {
//        case anyError
//    }
//
//    let disposeBag = DisposeBag()
//    func just() {
//        Observable.just("Hello").subscribe(onNext: { print("Value: \($0)") },
//                                          onError: { print("Hello Error: \($0)") },
//                                          onCompleted: { print("Hello Completed") },
//                                          onDisposed: { print ("disposed") })
//                                .disposed(by: disposeBag)
//
//        Observable.just("World").subscribe(onNext: { print("Value: \($0)") },
//                                           onError: { print("World Error: \($0)") },
//                                           onCompleted: { print("World Completed") },
//                                           onDisposed: { print ("World disposed") })
//                                .disposed(by: disposeBag)
//    }
//
//    func publishSubject() {
//        let subject = PublishSubject<String>()
//        subject.subscribe(onNext: { print("Publish Value: \($0)") },
//                          onError: { print("Publish Error: \($0)") },
//                          onCompleted: { print("Publish Completed") },
//                          onDisposed: { print ("Publish disposed") })
//               .disposed(by: disposeBag)
//        subject.on(.next("Sending to publish subject"))
//        subject.onNext("Sending more to publish subject")
//        subject.onError(MyError.anyError)
//        subject.on(.next("Sending even more to publish subject"))
//    }
//
//    func behaviorSubject() {
//        let subject = BehaviorSubject<String>(value: "0")
//        let firstSub = subject.subscribe(onNext: { print("Behavior1 Value: \($0)") },
//                                         onError: { print("Behavior1 Error: \($0)") },
//                                         onCompleted: { print("Behavior1 Completed") },
//                                         onDisposed: { print ("Behavior1 disposed") })
//        disposeBag.insert(firstSub)
//        subject.on(.next("1"))
//        subject.onNext("2")
//
//        let secondSub = subject.subscribe(onNext: { print("Behavior2 Value: \($0)") },
//                                         onError: { print("Behavior2 Error: \($0)") },
//                                         onCompleted: { print("Behavior2 Completed") },
//                                         onDisposed: { print ("Behavior2 disposed") })
//        disposeBag.insert(secondSub)
//
//        subject.on(.next("3"))
//        subject.onError(MyError.anyError)
//        subject.on(.next("4"))
//    }
//
//    func replaySubject() {
//        let subject = ReplaySubject<Int>.create(bufferSize: 2)
//        let firstSub = subject.subscribe(onNext: { print("Behavior1 Value: \($0)") },
//                                         onError: { print("Behavior1 Error: \($0)") },
//                                         onCompleted: { print("Behavior1 Completed") },
//                                         onDisposed: { print ("Behavior1 disposed") })
//        disposeBag.insert(firstSub)
//        subject.onNext(1)
//        subject.onNext(2)
//        subject.onNext(3)
//
//        let secondSub = subject.subscribe(onNext: { print("Behavior2 Value: \($0)") },
//                                         onError: { print("Behavior2 Error: \($0)") },
//                                         onCompleted: { print("Behavior2 Completed") },
//                                         onDisposed: { print ("Behavior2 disposed") })
//        disposeBag.insert(secondSub)
//
//        subject.onNext(4)
//        subject.onError(MyError.anyError)
//        subject.onNext(5)
//    }
//
//    func single(valid: Bool?) {
//        let singleObservable = Single<String>.create(subscribe: { singleObserver -> Disposable in
//            let disposable = Disposables.create { print("Disposed trait resources") }
//            guard let valid else { return disposable }
//            valid ? singleObserver(.success("Success")) : singleObserver(.failure(MyError.anyError))
//            return disposable
//        })
//
//        let subscription = singleObservable.subscribe { event in
//            switch event {
//            case .failure(let error):
//                print("Single Error: \(error)")
//            case .success(let value):
//                print("Single Value: \(value)")
//            }
//        }
//
//        disposeBag.insert(subscription)
//    }
//
//    func completable(willComplete: Bool?) {
//        let completable = Completable.create { completableObserver in
//            let disposable = Disposables.create { print("Disposed trait resources") }
//            guard let willComplete else { return disposable }
//            willComplete ? completableObserver(.completed) : completableObserver(.error(MyError.anyError))
//            return disposable
//        }
//
//        let subscription = completable.subscribe { event in
//            switch event {
//            case .error(let error):
//                print("Completable Error: \(error)")
//            case .completed:
//                print("Completable Done")
//            }
//        }
//
//        disposeBag.insert(subscription)
//    }
//
//    func maybe(willSendValue: Bool?) {
//        let maybe = Maybe<String>.create { maybeObserver in
//            let disposable = Disposables.create { print("Disposed trait resources") }
//            guard let willSendValue else {
//                maybeObserver(.completed)
//                return disposable
//            }
//            willSendValue ? maybeObserver(.success("Value")) : maybeObserver(.error(MyError.anyError))
//            return disposable
//        }
//
//        let subscription = maybe.subscribe { event in
//            switch event {
//            case .completed:
//                print("Maybe Done")
//            case .error(let error):
//                print("Maybe Error: \(error)")
//            case .success(let value):
//                print("Maybe Value: \(value)")
//            }
//        }
//
//        disposeBag.insert(subscription)
//    }
//}
