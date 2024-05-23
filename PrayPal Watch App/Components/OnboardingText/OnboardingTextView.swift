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

    var body: some View {
        VStack {
            Text("Have you prayed \(currentPrayerName) today?")
                .fontWeight(.regular)
                .font(.system(size: 21))
                .foregroundStyle(Color(.white))
        }
        .onReceive(locationManager.$province) { _ in
            updateCurrentPrayerName()
        }
        .onReceive(locationManager.$city) { _ in
            updateCurrentPrayerName()
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
}


#Preview {
    OnboardingTextView()
}


//import SwiftUI
//
//struct OnboardingTextView: View {
//    @StateObject private var locationManager = CurrentPrayerTimeLocationManager()
//    @State private var currentPrayerName: String = "Loading..."
//    @State private var timer: Timer? = nil
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Have you prayed \(currentPrayerName) today?")
//                .font(.system(size: 18))
//                .multilineTextAlignment(.center)
//                .lineLimit(3)
//                .truncationMode(.tail)
//        }
//        .onAppear {
//            startTimer()
//        }
//        .onDisappear {
//            timer?.invalidate()
//        }
//        .onReceive(locationManager.$province) { _ in
//            updateCurrentPrayerName()
//        }
//        .onReceive(locationManager.$city) { _ in
//            updateCurrentPrayerName()
//        }
//    }
//
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
//            updateCurrentPrayerName()
//        }
//    }
//
//    private func updateCurrentPrayerName() {
//        guard let location = locationManager.location else {
//            print("Location not available")
//            return
//        }
//
//        if let prayerTimes = loadPrayerTimes(for: Date(), province: locationManager.province, city: locationManager.city) {
//            currentPrayerName = getCurrentPrayerName(currentTime: Date(), prayerTimes: prayerTimes)
//        } else {
//            currentPrayerName = "Error loading prayer names"
//        }
//    }
//}
//
//
//#Preview {
//    OnboardingTextView()
//}
