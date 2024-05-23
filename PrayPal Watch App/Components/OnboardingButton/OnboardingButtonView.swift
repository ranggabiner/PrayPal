//
//  OnboardingButtonView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI
import UserNotifications

struct OnboardingButtonView: View {
    @AppStorage("currentPage") var currentPage: String = "OnBoardingView"
    
    var body: some View {
        VStack {
            Button(action: {
                currentPage = "NextPrayerView"
            }) {
                Text("Yes")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: 0xA2FC06))
            .cornerRadius(.infinity)
            
            Button(action: {
                requestNotificationPermissionAndSchedule()
                currentPage = "ClockInView"
            }) {
                Text("No")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: 0xA2FC06))
            .cornerRadius(.infinity)
        }
        .padding()
    }
    
    func requestNotificationPermissionAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
                scheduleNotification()
            } else if let error = error {
                print("Permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification() {
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
