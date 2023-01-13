//
//  ContentView.swift
//  Starter Project
//
//  Created by Evelyne Suto on 11.01.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TestView().ignoresSafeArea()
    }
}

enum Devices: String {
    case iPhone14 = "iPhone 14"
    case iPhone14ProMax = "iPhone 14 Pro Max"
    case iPadMini = "iPad mini (6th generation)"
    
    var preview: PreviewDevice {
        PreviewDevice(rawValue: rawValue)
    }
    
    var name: String { rawValue }
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
