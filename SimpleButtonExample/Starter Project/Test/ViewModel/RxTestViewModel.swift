//
//  RxTestViewModel.swift
//  Starter Project
//
//  Created by Evelyne Suto on 05.04.2023.
//

import Foundation
import RxSwift

class RxTestViewModel {
    let subject = BehaviorSubject<Int>(value: 0)

    func increase() {
        guard let currentValue = try? subject.value() else { return }
        subject.on(.next(currentValue + 1))
    }

    func decrease() {
        guard let currentValue = try? subject.value() else { return }
        subject.on(.next(currentValue - 1))
    }
}
