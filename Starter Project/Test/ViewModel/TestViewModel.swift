//
//  TestViewModel.swift
//  Starter Project
//
//  Created by Evelyne Suto on 13.01.2023.
//

import Foundation
import Combine

class TestViewModel {
    private(set) var value: Int = 0 {
        didSet {
            currentValue.send(value)
        }
    }
    let currentValue = CurrentValueSubject<Int, Never>(0)
    
    func increase() {
        value += 1
    }
    
    func decrease() {
        value -= 1
    }
}
