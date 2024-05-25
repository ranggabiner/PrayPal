//
//  OnboardingButtonView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI
import UserNotifications

struct OnboardingButtonView: View {
    @State private var prayerTime: String = "Loading..."
    @State private var fajrPrayerTime: String = "Loading..."
    @State private var sunrisePrayerTime: String = "Loading..."
    @State private var dhuhrPrayerTime: String = "Loading..."
    @State private var asrPrayerTime: String = "Loading..."
    @State private var maghribPrayerTime: String = "Loading..."
    @State private var ishaPrayerTime: String = "Loading..."
    @State private var currentPrayerTime: String = "Loading..."

    
    @State private var prayerTimeNotif: String = "Loading..."
    @AppStorage("currentPage") var currentPage: String = "OnBoardingView"
    @StateObject private var locationManager = CurrentPrayerTimeLocationManager()
    @State private var currentPrayerName: String = "Loading..."
    @State private var nextPrayerTime: Date?
    @State private var selectedInterval: Int = 1
    
    @AppStorage("currentName") var currentName: String = "Loading..."
    
    var body: some View {
        ZStack {
            NextPrayerTimeViewHiden(prayerTime: $prayerTime, fajrPrayerTime: $fajrPrayerTime, sunrisePrayerTime: $sunrisePrayerTime, dhuhrPrayerTime: $dhuhrPrayerTime, asrPrayerTime: $asrPrayerTime, maghribPrayerTime: $maghribPrayerTime, ishaPrayerTime: $ishaPrayerTime, currentPrayerTime: $currentPrayerTime)
                .hidden()

            NextPrayerTimeNotifView(prayerTimeNotif: $prayerTimeNotif, currentPrayerName: $currentPrayerName) //harus ada ini
                .hidden()
            VStack {
                Button(action: {
                    requestNotificationPermissionAndScheduleInterval()
                    currentPage = "ClockInView"
                }) {
                    Text("No")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(.infinity)
                
                Button(action: {
                    requestNotificationPermissionAndScheduleCalendar()
                    getCurrentName()
                    currentPage = "NextPrayerView"
                }) {
                    Text("Yes")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(.infinity)
            }
        }
    }
    
    func getCurrentName() {
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

        if currentTime >= fajrTime && currentTime < dhuhrTime {
            currentName = "Dhuhr"
        } else if currentTime >= dhuhrTime && currentTime < asrTime {
            currentName = "Asr"
        } else if currentTime >= asrTime && currentTime < maghribTime {
            currentName = "Maghrib"
        } else if currentTime >= maghribTime && currentTime < ishaTime {
            currentName = "Isha"
        } else if currentTime >= ishaTime || currentTime < fajrTime {
            currentName = "Fajr"
        }
    }
    
    func requestNotificationPermissionAndScheduleInterval() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
                scheduleNotificationInterval()
            } else if let error = error {
                print("Permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func requestNotificationPermissionAndScheduleCalendar() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
                scheduleNotificationForNextPrayer()
            } else if let error = error {
                print("Permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotificationForNextPrayer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let notificationTime = formatter.date(from: prayerTimeNotif) else {
            print("Failed to parse time string.")
            return
        }

        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)

        guard let scheduledTime = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) else {
            print("Could not calculate next prayer time.")
            return
        }

        if scheduledTime <= now {
            print("Scheduled time must be in the future.")
            return
        }
        
        // Schedule notifications with selected interval
        var customIntervals: [Int] = []
        for i in 1...50 {
            customIntervals.append(i * selectedInterval) // Interval waktu ditambahkan dengan kelipatan dari selectedInterval
        }

        // Melakukan perulangan untuk setiap interval waktu
        for interval in customIntervals {
            guard let notificationDate = calendar.date(byAdding: .minute, value: interval, to: scheduledTime) else {
                print("Gagal menghitung waktu notifikasi untuk interval \(interval) menit.")
                continue
            }
            let (title, subtitle) = getRandomTitleAndSubtitle()
            scheduleNotificationCalendar(at: notificationDate, withTitle: title, subtitle: subtitle)
        }
    }

    func scheduleNotificationCalendar(at date: Date, withTitle title: String, subtitle: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        let calendar = Calendar.current
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(date)!")
            }
        }
    }
    
    func scheduleNotificationInterval() {
        let (title, subtitle) = getRandomTitleAndSubtitle()

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(selectedInterval * 60), repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled!")
            }
        }
    }
    
//    private func updateCurrentPrayerName() {
//        guard let location = locationManager.location else {
//            print("Location not available")
//            return
//        }
//
//        if let prayerTimes = loadPrayerTimes(for: Date(), province: locationManager.province, city: locationManager.city) {
//            currentPrayerName = getCurrentPrayerName(currentTime: Date(), prayerTimes: prayerTimes)
//            nextPrayerTime = getNextPrayerTimeRemaining(currentTime: Date(), prayerTimes: prayerTimes)
//        } else {
//            currentPrayerName = "Error loading prayer times"
//        }
//    }
    
    func getRandomTitleAndSubtitle() -> (String, String) {
        let titlesAndSubtitles = [
            ("Peringatan Sholat", "Anda belum Sholat"),
            ("Waktu Sholat", "Saatnya sholat"),
            ("Ayo Sholat", "Waktunya sholat  sudah tiba"),
            ("Ingat Sholat", "Jangan lupa sholat"),
            ("Sholat  Sekarang", "Waktu sholat  telah tiba")
        ]
        return titlesAndSubtitles.randomElement() ?? ("Peringatan Sholat", "Saatnya Sholat")
    }
}

#Preview {
    OnboardingButtonView()
}
