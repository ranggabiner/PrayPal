//
//  OnboardingButtonView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI
import UserNotifications

struct OnboardingButtonView: View {
    @State private var prayerTimeNotif: String = "Loading..."
    @AppStorage("currentPage") var currentPage: String = "OnBoardingView"
    
    var body: some View {
        ZStack {
            NextPrayerTimeNotifView(prayerTimeNotif: $prayerTimeNotif) //harus ada ini
                .hidden()
            VStack {
                Button(action: {
                    requestNotificationPermissionAndScheduleCalendar()
                    currentPage = "NextPrayerView"
                }) {
                    Text("Yes")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
//                .background(Color(hex: 0xA2FC06))
                .cornerRadius(.infinity)
                
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
//                .background(Color(hex: 0xA2FC06))
                .cornerRadius(.infinity)
            }
            .padding()
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

        // Schedule notifications three times with 5 minutes interval
        let intervals = [0, 1, 3, 4, 6] // in minutes
        for interval in intervals {
            guard let notificationDate = calendar.date(byAdding: .minute, value: interval, to: scheduledTime) else {
                print("Failed to calculate notification time for interval \(interval) minutes.")
                continue
            }
            scheduleNotificationCalendar(at: notificationDate, withTitle: "Peringatan Sholat", subtitle: "Anda belum Sholat")
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
        let content = UNMutableNotificationContent()
        content.title = "Peringatan Sholat"
        content.subtitle = "Anda belum Sholat"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled!")
            }
        }
    }
}

#Preview {
    OnboardingButtonView()
}
