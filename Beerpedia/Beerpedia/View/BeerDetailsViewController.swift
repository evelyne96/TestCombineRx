//
//  BeerDetailsViewController.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 17.01.2023.
//

import Combine
import Foundation
import UIKit

class BeerDetailsViewController: UIViewController {
    private let viewModel: BeerViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        return label
    }()
    
    init(viewModel: BeerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentStack = UIStackView(arrangedSubviews: [imageView, descriptionLabel])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        view.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        bindViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewEvent.send(.onAppear)
    }
    
    private func bindViews() {
        imageView.image = viewModel.image.value
        descriptionLabel.text = viewModel.name
        
        viewModel.image.sink { [weak self] in
            self?.imageView.image = $0
        }.store(in: &cancellables)
    }
}
