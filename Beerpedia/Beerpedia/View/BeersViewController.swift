//
//  BeersViewController.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Combine
import Foundation
import SwiftUI
import UIKit

final class BeersViewController: UIViewController {
    typealias Cell = BeerCell
    typealias CellData = BeerViewModel
    
    private enum Section: CaseIterable {
        case beers
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        return collectionView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .secondaryLabel
        view.addSubview(label)
        return label
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource = {
        UICollectionViewDiffableDataSource<Section, CellData>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseID, for: indexPath) as? Cell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        activity.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activity)
        return activity
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    private(set) var viewModel: BeersViewModel
    
    init(viewModel: BeersViewModel = BeersViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        view.backgroundColor = .systemBackground
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseID)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        bindViewModel()
        viewModel.viewEvent.send(.onLoaded)
    }
    
    private func bindViewModel() {
        viewModel.error
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: errorLabel)
            .store(in: &subscriptions)
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] in
                $0 ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &subscriptions)
        
        viewModel.beers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
            self?.refreshBeers($0)
        }.store(in: &subscriptions)
    }
    
    private func refreshBeers(_ beers: [CellData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellData>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(beers, toSection: .beers)
        dataSource.apply(snapshot)
    }
}

extension BeersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.viewEvent.send(.didSelect(indexPath))
    }
}
