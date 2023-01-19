//
//  UIKit+Extensions.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation
import UIKit

protocol ReusableView {
    static var reuseID: String { get }
}

extension ReusableView {
    static var reuseID: String { String(describing: self) }
}

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
