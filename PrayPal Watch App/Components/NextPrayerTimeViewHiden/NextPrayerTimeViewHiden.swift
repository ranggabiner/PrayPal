//
//  NextPrayerTimeViewHiden.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 25/05/24.
//

import SwiftUI

struct NextPrayerTimeViewHiden: View {
    @AppStorage("currentPage") var currentPage: String = "NextPrayerView"
    @StateObject private var locationManager = NextPrayerTimeLocationManager()
    @Binding var prayerTime: String
    @Binding var fajrPrayerTime: String
    @Binding var sunrisePrayerTime: String
    @Binding var dhuhrPrayerTime: String
    @Binding var asrPrayerTime: String
    @Binding var maghribPrayerTime: String
    @Binding var ishaPrayerTime: String
    @Binding var currentPrayerTime: String
    @State private var nextPrayerName: String = "Loading..."
    @State private var currentPrayerName: String = "Loading..."
    @State private var timer: Timer? = nil
    

    var body: some View {
        VStack(spacing: 20) {
            Text("i")
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onReceive(locationManager.$province) { _ in
            updatePrayerTime()
        }
        .onReceive(locationManager.$city) { _ in
            updatePrayerTime()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updatePrayerTime()
        }
    }

    private func updatePrayerTime() {
        guard let location = locationManager.location else {
            print("Location not available")
            return
        }

        let currentTime = Date()

        if let prayerTimes = loadPrayerTimes(for: currentTime, province: locationManager.province, city: locationManager.city) {
            let nextPrayerInfo = getNextPrayerInfo(currentTime: currentTime, prayerTimes: prayerTimes)
            prayerTime = nextPrayerInfo.time
            nextPrayerName = nextPrayerInfo.name
            // Store prayer time separately
            fajrPrayerTime = prayerTimes.fajr
            sunrisePrayerTime = prayerTimes.sunrise
            dhuhrPrayerTime = prayerTimes.dhuhr
            asrPrayerTime = prayerTimes.asr
            maghribPrayerTime = prayerTimes.maghrib
            ishaPrayerTime = prayerTimes.isha

            // Set currentPrayerTime and currentPrayerName
            let currentPrayerInfo = getCurrentPrayerInfo(currentTime: currentTime, prayerTimes: prayerTimes)
            currentPrayerTime = currentPrayerInfo.time
            currentPrayerName = currentPrayerInfo.name
        } else {
            prayerTime = "Error loading prayer times"
            nextPrayerName = "Error"
            currentPrayerTime = "Error"
            currentPrayerName = "Error"
        }
    }

    private func getCurrentPrayerInfo(currentTime: Date, prayerTimes: PrayerTimes) -> (name: String, time: String) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        func timeToComponents(_ time: String) -> DateComponents? {
            guard let date = dateFormatter.date(from: time) else { return nil }
            return calendar.dateComponents([.hour, .minute], from: date)
        }

        func createDate(components: DateComponents) -> Date? {
            return calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: currentTime)
        }

        let prayerTimesList = [
            (name: "Fajr", time: prayerTimes.fajr),
            (name: "Sunrise", time: prayerTimes.sunrise),
            (name: "Dhuhr", time: prayerTimes.dhuhr),
            (name: "Asr", time: prayerTimes.asr),
            (name: "Maghrib", time: prayerTimes.maghrib),
            (name: "Isha", time: prayerTimes.isha)
        ]

        var previousPrayer: (name: String, time: String)? = nil

        for prayer in prayerTimesList {
            if let components = timeToComponents(prayer.time), let date = createDate(components: components), date > currentTime {
                if let previousPrayer = previousPrayer {
                    return (name: previousPrayer.name, time: previousPrayer.time)
                }
                break
            }
            previousPrayer = prayer
        }

        if let lastPrayer = prayerTimesList.last {
            return (name: lastPrayer.name, time: lastPrayer.time)
        }

        return (name: "Error", time: "Error")
    }

    private func getNextPrayerInfo(currentTime: Date, prayerTimes: PrayerTimes) -> (name: String, time: String) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        func timeToComponents(_ time: String) -> DateComponents? {
            guard let date = dateFormatter.date(from: time) else { return nil }
            return calendar.dateComponents([.hour, .minute], from: date)
        }

        func createDate(components: DateComponents) -> Date? {
            return calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: currentTime)
        }

        let prayerTimesList = [
            (name: "Fajr", time: prayerTimes.fajr),
            (name: "Sunrise", time: prayerTimes.sunrise),
            (name: "Dhuhr", time: prayerTimes.dhuhr),
            (name: "Asr", time: prayerTimes.asr),
            (name: "Maghrib", time: prayerTimes.maghrib),
            (name: "Isha", time: prayerTimes.isha)
        ]

        for prayer in prayerTimesList {
            if let components = timeToComponents(prayer.time), let date = createDate(components: components), date > currentTime {
                return (name: prayer.name, time: dateFormatter.string(from: date))
            }
        }

        // If the current time is past Isha, return the time for Fajr of the next day
        if let ishaComponents = timeToComponents(prayerTimes.isha), let ishaDate = createDate(components: ishaComponents), currentTime >= ishaDate {
            if let fajrComponents = timeToComponents(prayerTimes.fajr), let fajrDate = createDate(components: fajrComponents) {
                let nextDayFajrDate = calendar.date(byAdding: .day, value: 1, to: fajrDate)
                if let nextDayFajrDate = nextDayFajrDate {
                    return (name: "Fajr", time: dateFormatter.string(from: nextDayFajrDate))
                } else {
                    return (name: "Error", time: "Error")
                }
            }
        }

        return (name: "Error", time: "Error")
    }
}

#Preview {
    NextPrayerTimeViewHiden(prayerTime: .constant("Loading..."), fajrPrayerTime: .constant("Loading..."), sunrisePrayerTime: .constant("Loading..."), dhuhrPrayerTime: .constant("Loading..."), asrPrayerTime: .constant("Loading..."), maghribPrayerTime: .constant("Loading..."), ishaPrayerTime: .constant("Loading..."), currentPrayerTime: .constant("Loading..."))
}
