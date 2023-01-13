//
//  TestViewController.swift
//  Starter Project
//
//  Created by Evelyne Suto on 13.01.2023.
//

import Foundation
import UIKit
import SwiftUI

struct TestView: UIViewControllerRepresentable {
    typealias UIViewControllerType = TestViewController
    
    func makeUIViewController(context: Context) -> TestViewController {
        TestViewController()
    }
    
    func updateUIViewController(_ uiViewController: TestViewController, context: Context) {
        
    }
}

class TestViewController: UIViewController {
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("-", for: .normal)
        button.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        button.setContentHuggingPriority(.required, for: .vertical)
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
    }
}
