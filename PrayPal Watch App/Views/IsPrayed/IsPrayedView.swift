//
//  IsPrayedView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct IsPrayedView: View {
    var body: some View {
        ScrollView {
            VStack {
                HStack  {
                    HeaderView()
                    Spacer()
                }
                Spacer()
                IsPrayedTextView()
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
    IsPrayedView()
}
