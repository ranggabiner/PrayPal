//
//  ContentView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("currentPage") var currentPage: String = "OnboardingView"

    var body: some View {
        switch currentPage {
        case "OnboardingView":
            OnboardingView()
        case "NextPrayerView":
            NextPrayerView()
        case "ClockInView":
            ClockInView() 
        case "IsPrayedView":
            IsPrayedView()
        default:
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
