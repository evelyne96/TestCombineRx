//
//  InfoView.swift
//  Starter Project
//
//  Created by Evelyne Suto on 22.04.2023.
//

import SwiftUI

struct InfoView: View {
    let systemImageName: String
    let text: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .frame(height: 50)
            .overlay(
                HStack {
                    Image(systemName: systemImageName)
                        .foregroundColor(.indigo)
                    Text(text)
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                        .bold()
                    Spacer()
                }.padding(25)
            )
            .padding(10)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(systemImageName: "birthday.cake.fill",
                 text: "August 2019")
    }
}
