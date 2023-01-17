//
//  Coordinator.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 17.01.2023.
//

import Foundation
import UIKit

public protocol Coordinator : AnyObject {
    var childCoordinators: [Coordinator] { get set }

    // All coordinators will be initilised with a navigation controller
    init(navigationController: UINavigationController)

    func start()
}

