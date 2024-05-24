//
//  NextPrayerView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct NextPrayerView: View {
    @State private var prayerTime: String = "Loading..."
    @State private var sunrisePrayerTime: String = "Loading..."
    @AppStorage("currentPage") var currentPage: String = "NextPrayerView"
    
    // Timer to check the current time every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack {
                HeaderView()
                Spacer()
            }
            Spacer()
            NextPrayerTimeView(prayerTime: $prayerTime, sunrisePrayerTime: $sunrisePrayerTime)
            Spacer()
            FooterView()
        }
        .padding(.top, 12)
        .padding(.bottom, 10)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            checkPrayerTime()
        }
    }

    // Function to check if the current time matches the prayer time notification
    func checkPrayerTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Assuming prayerTimeNotif is in "HH:mm" format
        
        let currentTime = formatter.string(from: Date())
        
        if currentTime == prayerTime && currentTime != sunrisePrayerTime {
            currentPage = "ClockInView"
        }
    }
}

#Preview {
    NextPrayerView()
}
