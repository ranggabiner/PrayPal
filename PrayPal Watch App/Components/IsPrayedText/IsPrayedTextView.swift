//
//  IsPrayedTextView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct IsPrayedTextView: View {
    @StateObject private var locationManager = CurrentPrayerTimeLocationManager()
    @State private var BeforeCurrentPrayerName: String = "Loading..."
    @State private var nextPrayerTime: Date?

    var body: some View {
        VStack {
            Text("It looks like you haven't prayed \(BeforeCurrentPrayerName) today?")
                .fontWeight(.regular)
                .font(.system(size: 21))
                .foregroundStyle(Color(.white))
        }
        .onReceive(locationManager.$province) { _ in
            updateCurrentPrayerName()
        }
        .onReceive(locationManager.$city) { _ in
            updateCurrentPrayerName()
        }
    }

    private func updateCurrentPrayerName() {
        guard let location = locationManager.location else {
            print("Location not available")
            return
        }

        if let prayerTimes = loadPrayerTimes(for: Date(), province: locationManager.province, city: locationManager.city) {
            BeforeCurrentPrayerName = getBeforeCurrentPrayerName(currentTime: Date(), prayerTimes: prayerTimes)
        } else {
            BeforeCurrentPrayerName = "Error loading prayer times"
        }
    }
}


#Preview {
    IsPrayedTextView()
}
