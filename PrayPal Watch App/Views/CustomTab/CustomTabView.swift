//
//  CustomTabView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 26/05/24.
//

import SwiftUI

struct CustomTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Text("Home")
                }
            PrayerTimesView()
                .tabItem {
                    Text("Settings")
                }

        }   
    }
}

#Preview {
    CustomTabView()
}
