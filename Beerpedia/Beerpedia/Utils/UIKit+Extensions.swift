//
//  UIKit+Extensions.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation
import UIKit

extension UIEdgeInsets {
    init(uniform: CGFloat) {
        self.init(top: uniform, left: uniform, bottom: uniform, right: uniform)
    }
}

extension NSLayoutConstraint {
    func prioritized(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
