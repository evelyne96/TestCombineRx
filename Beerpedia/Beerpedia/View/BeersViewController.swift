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

struct UIKitBeersView: UIViewControllerRepresentable {
    typealias UIViewControllerType = BeersViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType { .init() }    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

class BeersViewController: UIViewController {
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
    
    private lazy var dataSource: UICollectionViewDiffableDataSource = {
        UICollectionViewDiffableDataSource<Section, CellData>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseID, for: indexPath) as? Cell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: BeerListViewModel
    
    init(viewModel: BeerListViewModel = BeerListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseID)
        collectionView.dataSource = dataSource
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.viewEvent.send(.onAppear)
    }
    
    private func bindViewModel() {
        viewModel.beers.sink { [weak self] beers in
            self?.didLoad(beers: beers)
        }.store(in: &subscriptions)
    }
    
    private func didLoad(beers: [CellData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellData>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(beers, toSection: .beers)
        dataSource.apply(snapshot)
    }
}
