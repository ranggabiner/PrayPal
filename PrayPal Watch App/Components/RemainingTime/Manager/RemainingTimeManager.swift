//
//  RemainingTimeManager.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import Foundation

func getNextPrayerTimeRemaining(currentTime: Date, prayerTimes: PrayerTimes) -> Date? {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"

    func timeToDate(_ time: String) -> Date? {
        guard let date = dateFormatter.date(from: time) else { return nil }
        return calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: calendar.component(.minute, from: date), second: 0, of: currentTime)
    }

    guard
        let fajrDate = timeToDate(prayerTimes.fajr),
        let sunriseDate = timeToDate(prayerTimes.sunrise),
        let dhuhrDate = timeToDate(prayerTimes.dhuhr),
        let asrDate = timeToDate(prayerTimes.asr),
        let maghribDate = timeToDate(prayerTimes.maghrib),
        let ishaDate = timeToDate(prayerTimes.isha)
    else {
        print("Error: Unable to create dates from prayer times")
        return nil
    }

    let prayerTimesArray: [Date] = [fajrDate, sunriseDate, dhuhrDate, asrDate, maghribDate, ishaDate].compactMap { $0 }

    let filteredPrayerTimes = prayerTimesArray.filter { $0 > currentTime }

    return filteredPrayerTimes.first
}

