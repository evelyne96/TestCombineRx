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
    
    private static let cellID = "beerCell"
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellID, for: indexPath) as? Cell else {
                return UICollectionViewCell()
            }
            // TODO: configure
            return cell
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Self.cellID)
        collectionView.dataSource = dataSource
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
