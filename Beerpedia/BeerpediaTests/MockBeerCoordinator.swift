//
//  MockBeerCoordinator.swift
//  BeerpediaTests
//
//  Created by Evelyne Suto on 20.01.2023.
//

import Foundation

class MockBeerCoordinator: BeerCoordinator {
    enum NavigationPath: Equatable {
        case showBeerDetails(_ viewModel: BeerViewModel)
    }
    var navigationPaths: [NavigationPath] = []
    
    func showDetailsFor(viewModel: BeerViewModel) {
        navigationPaths.append(.showBeerDetails(viewModel))
    }
}
