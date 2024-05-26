//
//  ClockInButtonView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//


import SwiftUI
import UserNotifications

struct ClockInButtonView: View {
    @State private var prayerTime: String = "Loading..."
    @State private var fajrPrayerTime: String = "Loading..."
    @State private var sunrisePrayerTime: String = "Loading..."
    @State private var dhuhrPrayerTime: String = "Loading..."
    @State private var asrPrayerTime: String = "Loading..."
    @State private var maghribPrayerTime: String = "Loading..."
    @State private var ishaPrayerTime: String = "Loading..."

    @State private var prayerTimeNotif: String = "Loading..."
    @AppStorage("currentPage") var currentPage: String = "ClockInView"
    @State private var showAlert = false
    @StateObject private var locationManager = CurrentPrayerTimeLocationManager()
    @State private var currentPrayerName: String = "Loading..."
    @State private var nextPrayerTime: Date?
    @State private var selectedInterval: Int = 1
    @State private var currentPrayerTime: String = "Loading..."
    @AppStorage("currentName") var currentName: String = "Loading..."

    var body: some View {
        ZStack {
            NextPrayerTimeViewHiden(prayerTime: $prayerTime, fajrPrayerTime: $fajrPrayerTime, sunrisePrayerTime: $sunrisePrayerTime, dhuhrPrayerTime: $dhuhrPrayerTime, asrPrayerTime: $asrPrayerTime, maghribPrayerTime: $maghribPrayerTime, ishaPrayerTime: $ishaPrayerTime, currentPrayerTime: $currentPrayerTime)
                .hidden()
            NextPrayerTimeNotifView(prayerTimeNotif: $prayerTimeNotif, currentPrayerName: $currentPrayerName) //harus ada ini
                .hidden()
            VStack {
                Button(action: {
                    showAlert = true
                }) {
                    Text("PRAY NOW")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .background(Color(hex: 0xD42323))
                .cornerRadius(.infinity)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Warning"),
                        message: Text("PRAY NOW only when you are ready to pray \(currentPrayerName). Are you ready to pray \(currentPrayerName)?"),
                        primaryButton: .default(Text("Yes"), action: {
                            // Cancel all notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            print("All notifications cancelled!")
                            print("User is ready to pray.")
                            
                            // currentName
                            getCurrentName()
                            print("currentName: \(currentName)")
                            
                            // Schedule the next prayer notification
                            scheduleNotificationForNextPrayer()
                            currentPage = "NextPrayerView"
                        }),
                        secondaryButton: .cancel(Text("No"), action: {
                            print("User is not ready to pray.")
                        })
                    )
                }
            }
        }
        .onReceive(locationManager.$province) { _ in
            updateCurrentPrayerName()
        }
        .onReceive(locationManager.$city) { _ in
            updateCurrentPrayerName()
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
            scheduleNotification(at: notificationDate, withTitle: title, subtitle: subtitle)
        }
    }

    func getRandomTitleAndSubtitle() -> (String, String) {
        let titlesAndSubtitles = [
            ("Peringatan Sholat", "Anda belum Sholat"),
            ("Waktu Sholat", "Saatnya sholat"),
            ("Ayo Sholat", "Waktunya sholat sudah tiba"),
            ("Ingat Sholat", "Jangan lupa sholat "),
            ("Sholat Sekarang", "Waktu sholat telah tiba")
        ]
        return titlesAndSubtitles.randomElement() ?? ("Peringatan Sholat", "Saatnya Sholat")
    }

    func scheduleNotification(at date: Date, withTitle title: String, subtitle: String) {
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
    ClockInButtonView()
}
