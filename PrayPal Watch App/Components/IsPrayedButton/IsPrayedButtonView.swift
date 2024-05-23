//
//  IsPrayedButtonView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI
import UserNotifications

struct IsPrayedButtonView: View {
    @AppStorage("currentPage") var currentPage: String = "IsPrayedView"
    
    var body: some View {
        VStack {
            Button(action: {
                // Cancel all notifications
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("All notifications cancelled!")
                print("User is ready to pray.")
                
                // now notification
                scheduleNotificationInterval()
                currentPage = "ClockInview"
            }) {
                Text("True")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(.infinity)
            
            Button(action: {
                // Cancel all notifications
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("All notifications cancelled!")
                print("User is ready to pray.")
                
                // now notification
                scheduleNotificationInterval()
                currentPage = "ClockInview"
            }) {
                Text("False")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(.infinity)
        }
        .padding()
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
    IsPrayedButtonView()
}
