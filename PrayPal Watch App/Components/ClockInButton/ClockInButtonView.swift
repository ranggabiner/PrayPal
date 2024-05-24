//
//  ClockInButtonView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//


import SwiftUI
import UserNotifications

struct ClockInButtonView: View {
    @State private var prayerTimeNotif: String = "Loading..."
    @AppStorage("currentPage") var currentPage: String = "ClockInView"
    @State private var showAlert = false
    @StateObject private var locationManager = CurrentPrayerTimeLocationManager()
    @State private var currentPrayerName: String = "Loading..."
    @State private var nextPrayerTime: Date?

    var body: some View {
        ZStack {
            NextPrayerTimeNotifView(prayerTimeNotif: $prayerTimeNotif) //harus ada ini
                .hidden()
            VStack {
                Button(action: {
                    showAlert = true
                }) {
                    Text("CLOCK IN")
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
                        message: Text("Clock in only when you are ready to pray. Are you ready to pray now?"),
                        primaryButton: .default(Text("Yes"), action: {
                            // Cancel all notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            print("All notifications cancelled!")
                            print("User is ready to pray.")
                            
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

        // Schedule notifications multiple times with 5 minutes interval
        let intervals = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25] // in minutes
        for interval in intervals {
            guard let notificationDate = calendar.date(byAdding: .minute, value: interval, to: scheduledTime) else {
                print("Failed to calculate notification time for interval \(interval) minutes.")
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
