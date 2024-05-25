//
//  NextPrayerView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct NextPrayerView: View {
    @State private var prayerTime: String = "Loading..."
    @State private var fajrPrayerTime: String = "Loading..."
    @State private var sunrisePrayerTime: String = "Loading..."
    @State private var dhuhrPrayerTime: String = "Loading..."
    @State private var asrPrayerTime: String = "Loading..."
    @State private var maghribPrayerTime: String = "Loading..."
    @State private var ishaPrayerTime: String = "Loading..."
    @State private var currentPrayerTime: String = "Loading..."
    @State private var currentPrayerName: String = "Loading..."
    @State private var prayerTimeNotif: String = "Loading..."
    @AppStorage("currentPage") var currentPage: String = "NextPrayerView"
    @AppStorage("currentName") var currentName: String = "ClockInView"
    
    
    // Timer to check the current time every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            NextPrayerTimeNotifView(prayerTimeNotif: $prayerTimeNotif, currentPrayerName: $currentPrayerName) //harus ada ini
                .hidden()
            ClockInButtonView()
                .hidden()
            VStack {
                HStack {
                    HeaderView()
                    Spacer()
                }
                Spacer()
                NextPrayerTimeView(prayerTime: $prayerTime, fajrPrayerTime: $fajrPrayerTime, sunrisePrayerTime: $sunrisePrayerTime, dhuhrPrayerTime: $dhuhrPrayerTime, asrPrayerTime: $asrPrayerTime, maghribPrayerTime: $maghribPrayerTime, ishaPrayerTime: $ishaPrayerTime, currentPrayerTime: $currentPrayerTime)
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
    }

    // Function to check if the current time matches the prayer time notification
    func checkPrayerTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let currentTime = formatter.date(from: formatter.string(from: Date())),
              let fajrTime = formatter.date(from: fajrPrayerTime),
              let dhuhrTime = formatter.date(from: dhuhrPrayerTime),
              let asrTime = formatter.date(from: asrPrayerTime),
              let maghribTime = formatter.date(from: maghribPrayerTime),
              let ishaTime = formatter.date(from: ishaPrayerTime) else {
            return
        }

        if currentTime >= fajrTime && currentTime < dhuhrTime && currentPrayerName == currentName {
            currentPage = "ClockInView"
        } else if currentTime >= dhuhrTime && currentTime < asrTime && currentPrayerName == currentName {
            currentPage = "ClockInView"
        } else if currentTime >= asrTime && currentTime < maghribTime && currentPrayerName == currentName {
            currentPage = "ClockInView"
        } else if currentTime >= maghribTime && currentTime < ishaTime && currentPrayerName == currentName {
            currentPage = "ClockInView"
        } else if ((currentTime >= ishaTime) || (currentTime < fajrTime)) && currentPrayerName == currentName {
            currentPage = "ClockInView"
        }
    }

}

#Preview {
    NextPrayerView()
}
