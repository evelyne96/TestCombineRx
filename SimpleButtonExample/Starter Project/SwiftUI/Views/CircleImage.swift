//
//  CircleImage.swift
//  Starter Project
//
//  Created by Evelyne Suto on 22.04.2023.
//

import SwiftUI

struct CircleImage: View {
    let image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(style: .init(lineWidth: 5))
                    .foregroundColor(.white)
                    .padding(-5)
            )
    }
}
struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image: "cato")
            .previewLayout(.sizeThatFits)
    }
}
