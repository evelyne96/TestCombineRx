//
//  BeerCell.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Combine
import Foundation
import UIKit

final class BeerCell: UICollectionViewCell, ReusableView {
    private enum UIConstants {
        static var spacing: CGFloat = 8
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var name: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private lazy var firstBrewed: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private lazy var contributed: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let labelStack = UIStackView(arrangedSubviews: [name, firstBrewed, contributed])
        labelStack.axis  = .vertical
        labelStack.alignment = .leading
        
        let contentStack = UIStackView(arrangedSubviews: [imageView, labelStack])
        contentStack.axis  = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = UIConstants.spacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(uniform: UIConstants.spacing)
        
        contentView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).prioritized(.defaultHigh),
            imageView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.25)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
        
        imageView.image = nil
        name.text = nil
        firstBrewed.text = nil
        contributed.text = nil
    }
    
    func configure(with viewModel: BeerViewModel) {
        name.text = viewModel.name
        firstBrewed.text = viewModel.firstBrewed
        contributed.text = viewModel.contributedBy
        
        // start image loading
        viewModel.imagePublisher.sink { _ in }.store(in: &subscriptions)
        
        // setup received data
        viewModel.image
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageView)
            .store(in: &subscriptions)
    }
}
