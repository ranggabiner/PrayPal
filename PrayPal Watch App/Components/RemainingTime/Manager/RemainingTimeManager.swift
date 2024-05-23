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
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

    guard
        let fajrDate = dateFormatter.date(from: "\(calendar.component(.year, from: currentTime))-\(calendar.component(.month, from: currentTime))-\(calendar.component(.day, from: currentTime)) \(prayerTimes.fajr)"),
        let sunriseDate = dateFormatter.date(from: "\(calendar.component(.year, from: currentTime))-\(calendar.component(.month, from: currentTime))-\(calendar.component(.day, from: currentTime)) \(prayerTimes.sunrise)"),
        let dhuhrDate = dateFormatter.date(from: "\(calendar.component(.year, from: currentTime))-\(calendar.component(.month, from: currentTime))-\(calendar.component(.day, from: currentTime)) \(prayerTimes.dhuhr)"),
        let asrDate = dateFormatter.date(from: "\(calendar.component(.year, from: currentTime))-\(calendar.component(.month, from: currentTime))-\(calendar.component(.day, from: currentTime)) \(prayerTimes.asr)"),
        let maghribDate = dateFormatter.date(from: "\(calendar.component(.year, from: currentTime))-\(calendar.component(.month, from: currentTime))-\(calendar.component(.day, from: currentTime)) \(prayerTimes.maghrib)"),
        let ishaDate = dateFormatter.date(from: "\(calendar.component(.year, from: currentTime))-\(calendar.component(.month, from: currentTime))-\(calendar.component(.day, from: currentTime)) \(prayerTimes.isha)")
    else {
        print("Error: Unable to create dates from prayer times")
        return nil
    }

    let prayerTimesArray: [Date] = [fajrDate, sunriseDate, dhuhrDate, asrDate, maghribDate, ishaDate].compactMap { $0 }

    let filteredPrayerTimes = prayerTimesArray.filter { $0 > currentTime }

    if let nextPrayerTime = filteredPrayerTimes.first {
        // Check if the next prayer is fajr and it's after isha of the current day
        if prayerTimes.fajr == dateFormatter.string(from: nextPrayerTime) && calendar.compare(ishaDate, to: currentTime, toGranularity: .day) == .orderedAscending {
            // Find the fajr time of the next day
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentTime) else { return nil }
            guard let nextDayFajrDate = dateFormatter.date(from: "\(calendar.component(.year, from: nextDay))-\(calendar.component(.month, from: nextDay))-\(calendar.component(.day, from: nextDay)) \(prayerTimes.fajr)") else { return nil }
            return nextDayFajrDate
        } else {
            return nextPrayerTime
        }
    } else {
        // If there's no prayer left for the day, return fajr of the next day
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentTime) else { return nil }
        guard let nextDayFajrDate = dateFormatter.date(from: "\(calendar.component(.year, from: nextDay))-\(calendar.component(.month, from: nextDay))-\(calendar.component(.day, from: nextDay)) \(prayerTimes.fajr)") else { return nil }
        return nextDayFajrDate
    }
}
