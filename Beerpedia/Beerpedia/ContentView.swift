//
//  ContentView.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            UIKitBeersView()
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
