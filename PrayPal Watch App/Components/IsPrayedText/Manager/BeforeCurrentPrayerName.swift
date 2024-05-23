//
//  BeforeCurrentPrayerName.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import Foundation

func getBeforeCurrentPrayerName(currentTime: Date, prayerTimes: PrayerTimes) -> String {
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
    
    guard
        let ishaComponents = timeToComponents(prayerTimes.isha),
        let maghribComponents = timeToComponents(prayerTimes.maghrib),
        let asrComponents = timeToComponents(prayerTimes.asr),
        let dhuhrComponents = timeToComponents(prayerTimes.dhuhr),
        let sunriseComponents = timeToComponents(prayerTimes.sunrise),
        let fajrComponents = timeToComponents(prayerTimes.fajr)
    else {
        print("Error: Invalid prayer times format")
        return "Invalid prayer times"
    }
    
    guard
        let ishaTime = createDate(components: ishaComponents),
        let maghribTime = createDate(components: maghribComponents),
        let asrTime = createDate(components: asrComponents),
        let dhuhrTime = createDate(components: dhuhrComponents),
        let sunriseTime = createDate(components: sunriseComponents),
        let fajrTime = createDate(components: fajrComponents)
    else {
        print("Error: Unable to create dates from components")
        return "Invalid prayer times"
    }
    
    // Array of prayer times in reverse order
    let prayerTimesArray = [ishaTime, maghribTime, asrTime, dhuhrTime, sunriseTime, fajrTime].sorted(by: >)
    
    for prayerTime in prayerTimesArray {
        if currentTime >= prayerTime {
            if prayerTime == ishaTime {
                return "Maghrib"
            } else if prayerTime == maghribTime {
                return "Asr"
            } else if prayerTime == asrTime {
                return "Dhuhr"
            } else if prayerTime == dhuhrTime {
                return "Sunrise"
            } else if prayerTime == sunriseTime {
                return "Fajr"
            }
        }
    }
    
    // If current time is before Fajr, return Isha
    return "Isha"
}
