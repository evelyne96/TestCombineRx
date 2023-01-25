//
//  BeerDetailsViewController.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 17.01.2023.
//

import Combine
import Foundation
import UIKit

final class BeerDetailsViewController: UIViewController {
    private enum UIConstants {
        static var spacing: CGFloat = 16
    }
    
    private let viewModel: BeerViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var name: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title1)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var firstBrewed: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var contributed: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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
        view.backgroundColor = .systemBackground
        let labelStack = UIStackView(arrangedSubviews: [name, firstBrewed, contributed])
        labelStack.axis  = .vertical
        labelStack.alignment = .center
        labelStack.spacing = UIConstants.spacing
        labelStack.isLayoutMarginsRelativeArrangement = true
        labelStack.layoutMargins = UIEdgeInsets(uniform: UIConstants.spacing)
        
        let contentStack = UIStackView(arrangedSubviews: [imageView, labelStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = UIConstants.spacing
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(uniform: UIConstants.spacing)
        view.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        bindViews()
        viewModel.viewEvent.send(.onLoaded)
    }
    
    private func bindViews() {
        name.text = viewModel.name
        firstBrewed.text = viewModel.firstBrewed
        contributed.text = viewModel.contributedBy
        
        viewModel.image
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageView)
            .store(in: &cancellables)
    }
}
