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

        // Schedule first notification
        scheduleNotification(at: scheduledTime, withTitle: "Peringatan Sholat", subtitle: "Anda belum Sholat")

        // Calculate time for second notification (5 minutes after the first)
        guard let secondScheduledTime = calendar.date(byAdding: .minute, value: 5, to: scheduledTime) else {
            print("Failed to calculate time for second notification.")
            return
        }

        // Schedule second notification
        scheduleNotification(at: secondScheduledTime, withTitle: "Peringatan Sholat", subtitle: "Anda masih belum Sholat")
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

    
}

#Preview {
    ClockInButtonView()
}
