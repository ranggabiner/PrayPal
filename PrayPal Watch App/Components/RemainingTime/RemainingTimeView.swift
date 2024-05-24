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
            // Check if the current time is between sunrise and Dhuhr
            if let sunriseTime = loadPrayerTimes(for: Date(), province: locationManager.province, city: locationManager.city)?.sunrise,
               let dhuhrTime = loadPrayerTimes(for: Date(), province: locationManager.province, city: locationManager.city)?.dhuhr,
               let sunriseDateTime = combineDateAndTime(date: Date(), time: sunriseTime),
               let dhuhrDateTime = combineDateAndTime(date: Date(), time: dhuhrTime),
               now >= sunriseDateTime && now < dhuhrDateTime {
                   countdownString = "00:00:00"
                   return
            }

            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: nextPrayerTime)
            countdownString = String(format: "%02d:%02d:%02d", components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
        } else {
            countdownString = "Prayer time passed"
        }
    }



    private func combineDateAndTime(date: Date, time: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let timeDate = dateFormatter.date(from: time) else { return nil }
        let calendar = Calendar.current
        return calendar.date(bySettingHour: calendar.component(.hour, from: timeDate), minute: calendar.component(.minute, from: timeDate), second: 0, of: date)
    }

}


#Preview {
    RemainingTimeView()
}
