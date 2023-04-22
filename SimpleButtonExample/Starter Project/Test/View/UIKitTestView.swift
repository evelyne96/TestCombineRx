//
//  UIKitTestView.swift
//  Starter Project
//
//  Created by Evelyne Suto on 05.04.2023.
//

import Foundation
import SwiftUI
import UIKit

struct UIKitTestView: UIViewControllerRepresentable {
    typealias UIViewControllerType = RxTestViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
