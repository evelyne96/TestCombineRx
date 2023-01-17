//
//  AppCoordinator.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 17.01.2023.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    let navigationController: UINavigationController
    
    required init(navigationController: UINavigationController = .init()) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        let viewModel = BeersViewModel(coordinator: self)
        let mainVC = BeersViewController(viewModel: viewModel)
        navigationController.pushViewController(mainVC, animated: false)
    }
}

// Beer View Coordinators
extension AppCoordinator {
    func showDetailsFor(viewModel: BeerViewModel) {
        let vc = BeerDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
