//
//  RemainingTimeView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//


import SwiftUI

struct RemainingTimeView: View {
    @StateObject private var locationManager = CurrentPrayerTimeLocationManager()
    @State private var currentPrayerName: String = "Loading..."
    @State private var nextPrayerTime: Date?
    @State private var countdownString: String = "Loading..."
    @State private var timer: Timer? = nil
    

    var body: some View {
        VStack {
            Text(currentPrayerName)
                .fontWeight(.regular)
                .font(.system(size: 21))
                .foregroundStyle(Color(.white))
            Text(countdownString)
                .fontWeight(.regular)
                .font(.system(size: 24))
                .foregroundStyle(Color(hex: 0xA2FC06))
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onReceive(locationManager.$province) { _ in
            updateCurrentPrayerName()
        }
        .onReceive(locationManager.$city) { _ in
            updateCurrentPrayerName()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateCurrentPrayerName()
            updateCountdownString()
        }
    }

    private func updateCurrentPrayerName() {
        guard let location = locationManager.location else {
            print("Location not available")
            return
        }

        if let prayerTimes = loadPrayerTimes(for: Date(), province: locationManager.province, city: locationManager.city) {
            currentPrayerName = getCurrentPrayerName(currentTime: Date(), prayerTimes: prayerTimes)
            nextPrayerTime = getNextPrayerTimeRemaining(currentTime: Date(), prayerTimes: prayerTimes)
        } else {
            currentPrayerName = "Error loading prayer times"
        }
    }

    private func updateCountdownString() {
        guard let nextPrayerTime = nextPrayerTime else {
            countdownString = "Next prayer time unknown"
            return
        }

        let now = Date()
        if now < nextPrayerTime {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: nextPrayerTime)
            countdownString = String(format: "%02d:%02d:%02d", components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
        } else {
            countdownString = "Prayer time passed"
        }
    }
}


#Preview {
    RemainingTimeView()
}
