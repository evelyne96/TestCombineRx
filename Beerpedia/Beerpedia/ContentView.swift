//
//  ContentView.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import SwiftUI
import UIKit

struct UIKitContentView: UIViewControllerRepresentable {
    typealias UIViewControllerType = BeersViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(viewModel: BeersViewModel())
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

struct ContentView: View {
    var body: some View {
        VStack {
            UIKitContentView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(Devices.iPhone14.preview)
            .previewDisplayName(Devices.iPhone14.name)
        
        ContentView()
            .previewDevice(Devices.iPhone14ProMax.preview)
            .previewDisplayName(Devices.iPhone14ProMax.name)
        
        ContentView()
            .previewDevice(Devices.iPadMini.preview)
            .previewDisplayName(Devices.iPadMini.name)
    }
}
