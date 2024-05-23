//
//  OnboardingView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct OnboardingView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                HStack  {
                    HeaderView()
                    Spacer()
                }
                Spacer()
                OnboardingTextView()
                Spacer()
                OnboardingButtonView()
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingView()
}
