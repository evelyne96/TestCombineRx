//
//  TestViewModel.swift
//  Starter Project
//
//  Created by Evelyne Suto on 13.01.2023.
//

import Foundation
import Combine

class TestViewModel {
    enum ButtonEvent {
        case increase
        case decrease
        
        var intValue: Int {
            switch self {
            case .increase:
                return 1
            case .decrease:
                return -1
            }
        }
    }
    
    private(set) var value: Int = 0 {
        didSet {
            currentValue.send(value)
        }
    }
    private var cancellables = Set<AnyCancellable>()
    let currentValue = CurrentValueSubject<Int, Never>(0)
    let buttonEvents = PassthroughSubject<ButtonEvent, Never>()
    
    init() {
        buttonEvents.sink { [weak self] event in
            self?.value += event.intValue
        }.store(in: &cancellables)
    }
}
