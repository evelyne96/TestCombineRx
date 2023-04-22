//
//  AvatarView.swift
//  Starter Project
//
//  Created by Evelyne Suto on 22.04.2023.
//

import Foundation
import SwiftUI

struct AvatarView: View {
    var body: some View {
            ZStack {
                Color(.systemMint)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        CircleImage(image: "cato")
                        
                        Text("Robin")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                        
                        Divider()
                        
                        InfoView(systemImageName: "birthday.cake.fill",
                                 text: "August 2019")
                        
                        InfoView(systemImageName: "fork.knife",
                                 text: "Acana")
                        
                        InfoView(systemImageName: "figure.2.and.child.holdinghands",
                                 text: "Zoli & Eve")
                    }.padding(10)
                }
            }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView()
            .previewDevice(Devices.iPhone14.preview)
            .previewDisplayName(Devices.iPhone14.name)
        
        AvatarView()
            .previewDevice(Devices.iPhone14ProMax.preview)
            .previewDisplayName(Devices.iPhone14ProMax.name)
        
        AvatarView()
            .previewDevice(Devices.iPadMini.preview)
            .previewDisplayName(Devices.iPadMini.name)
    }
}
