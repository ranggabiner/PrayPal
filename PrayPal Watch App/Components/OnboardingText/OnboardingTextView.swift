//
//  OnboardingTextView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct OnboardingTextView: View {
    @StateObject private var locationManager = CurrentPrayerTimeLocationManager()
    @State private var currentPrayerName: String = "Loading..."
    @State private var nextPrayerTime: Date?
    @State private var timer: Timer? = nil
    @State private var prayerTimeNotif: String = "Loading..."


    var body: some View {
        ZStack {
            NextPrayerTimeNotifView(prayerTimeNotif: $prayerTimeNotif, currentPrayerName: $currentPrayerName) //harus ada ini
                .hidden()

            VStack {
                Text("Have you prayed \(currentPrayerName) today?")
                    .fontWeight(.regular)
                    .font(.system(size: 21))
                    .foregroundStyle(Color(.white))
            }
        }
    }
    
}


#Preview {
    OnboardingTextView()
}
