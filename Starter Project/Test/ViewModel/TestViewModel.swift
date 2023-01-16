//
//  TestViewModel.swift
//  Starter Project
//
//  Created by Evelyne Suto on 13.01.2023.
//

import Foundation
import Combine

class TestViewModel {
    let currentValue = CurrentValueSubject<Int, Never>(0)
    
    func increase() {
        currentValue.send(currentValue.value + 1)
    }
    
    func decrease() {
        currentValue.send(currentValue.value - 1)
    }
}
