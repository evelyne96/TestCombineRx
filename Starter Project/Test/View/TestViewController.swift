//
//  TestViewController.swift
//  Starter Project
//
//  Created by Evelyne Suto on 13.01.2023.
//

import Foundation
import Combine
import SwiftUI
import UIKit

struct TestView: UIViewControllerRepresentable {
    typealias UIViewControllerType = TestViewController
    
    func makeUIViewController(context: Context) -> TestViewController {
        TestViewController()
    }
    
    func updateUIViewController(_ uiViewController: TestViewController, context: Context) {
        
    }
}

class TestViewController: UIViewController {
    private let viewModel = TestViewModel()
    private var cancellables = Set<AnyCancellable>()
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("-", for: .normal)
        button.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var currentValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.text = "0"
        
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let buttonStack = UIStackView(arrangedSubviews: [plusButton, minusButton])
        buttonStack.distribution = .fillEqually
        let contentStack = UIStackView(arrangedSubviews: [currentValueLabel, buttonStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        view.addSubview(contentStack)
        return contentStack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
        NSLayoutConstraint.activate([
            contentStack.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        bindViews()
    }
    
    private func bindViews() {
        viewModel.currentValue.map { "Value: \($0)"}.sink { [weak self] text in
            self?.currentValueLabel.text = text
        }.store(in: &cancellables)
    }
    
    @objc private func increaseTapped() {
        viewModel.buttonEvents.send(.increase)
    }
    
    @objc private func decreaseTapped() {
        viewModel.buttonEvents.send(.decrease)
    }
}
