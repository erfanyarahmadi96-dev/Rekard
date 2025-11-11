//
//  SplashScreen.swift
//  Rekard
//
//  Created by Erfan Yarahmadi on 04/11/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            LinearGradient.appBackground.ignoresSafeArea()

                
            VStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .padding(.top, 100)
                Text("Rekard")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                Text("Learn. Recall. Rekard")
                    .padding(.top, 330)
                    .font(.default)
            }
            .padding(.bottom)
        }
        
    }
}


#Preview {
    SplashScreen()
}
