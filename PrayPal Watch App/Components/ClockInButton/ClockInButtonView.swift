//
//  ClockInButtonView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI
import UserNotifications

struct ClockInButtonView: View {
    @State private var inputTime: String = "Loading..."
    @StateObject private var locationManager = NextPrayerTimeLocationManager()
    @State var prayerTime: String = "Loading..." {
        didSet {
            inputTime = prayerTime
        }
    }
    @State private var nextPrayerName: String = "Loading..."
    @State private var timer: Timer? = nil
    @AppStorage("currentPage") var currentPage: String = "ClockInView"
    @State private var showAlert = false
    
    var body: some View {
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
                    //cancel notif
//                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//                    print("All notifications cancelled!")
                    print("User is ready to pray.")
                    
                    // push notif (kalo gak bisa, coba pakai dispatchque)
                            scheduleNotificationManually(at: inputTime)
                    currentPage = "NextPrayerView"
                }),
                secondaryButton: .cancel(Text("No"), action: {
                    print("User is not ready to pray.")
                })
            )
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
        
        if let prayerTimes = loadPrayerTimes(for: Date(), province: locationManager.province, city: locationManager.city) {
            let nextPrayerInfo = getNextPrayerInfo(currentTime: Date(), prayerTimes: prayerTimes)
            prayerTime = nextPrayerInfo.time
            nextPrayerName = nextPrayerInfo.name
        } else {
            prayerTime = "Error loading prayer times"
            nextPrayerName = "Error"
        }
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
        if let fajrComponents = timeToComponents(prayerTimes.fajr), let fajrDate = createDate(components: fajrComponents) {
            let nextDayFajrDate = calendar.date(byAdding: .day, value: 1, to: fajrDate)
            let nextPrayerTime = nextDayFajrDate != nil ? dateFormatter.string(from: nextDayFajrDate!) : "Error"
            return (name: "Fajr", time: nextPrayerTime)
        }
        
        return (name: "Error", time: "Error")
    }
    
    func scheduleNotificationManually(at timeString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let notificationTime = formatter.date(from: timeString) else {
            print("Failed to parse time string.")
            return
        }

        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        var components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        components.year = calendar.component(.year, from: now)
        components.month = calendar.component(.month, from: now)
        components.day = calendar.component(.day, from: now)

        guard let scheduledTime = calendar.date(from: components),
              scheduledTime > now else {
            print("Scheduled time must be in the future.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Peringatan Sholat TELAH TIBA"
        content.subtitle = "Anda belum Sholat"
        content.sound = UNNotificationSound.default

        var triggerComponents = DateComponents()
        triggerComponents.hour = calendar.component(.hour, from: scheduledTime)
        triggerComponents.minute = calendar.component(.minute, from: scheduledTime)

        // Create a repeating notification every 5 minutes
        for minuteOffset in stride(from: 0, to: 60, by: 1) {
            var repeatingComponents = triggerComponents
            repeatingComponents.minute = (triggerComponents.minute! + minuteOffset) % 60
            let trigger = UNCalendarNotificationTrigger(dateMatching: repeatingComponents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error adding notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled for \(timeString) with a 5-minute repeat interval!")
                }
            }
        }
    }
}

#Preview {
    ClockInButtonView()
}
