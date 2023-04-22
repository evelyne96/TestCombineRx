//
//  RxTestViewController.swift
//  Starter Project
//
//  Created by Evelyne Suto on 05.04.2023.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class RxTestViewController: UIViewController {
    private let viewModel = RxTestViewModel()
    private var disposeBag = DisposeBag()
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
        plusButton.rx.tap.subscribe { [weak self] _ in
            self?.viewModel.increase()
        }
        .disposed(by: disposeBag)
        
        minusButton.rx.tap.subscribe { [weak self] _ in
            self?.viewModel.decrease()
        }
        .disposed(by: disposeBag)
        
        viewModel.subject
            .map { "\($0)" }
            .bind(to: currentValueLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
