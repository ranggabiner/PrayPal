//
//  PickerPrayerTimesView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 26/05/24.
//

import SwiftUI

struct PickerPrayerTimesView: View {
    @StateObject var locationManager = LocationManager()
    @State private var selectedPrayerIndex = 0
    
    var body: some View {
        VStack {
            Picker(selection: $selectedPrayerIndex, label: Text("")) {
                ForEach(0..<Prayer.allCases.count) { index in
                    Text(Prayer.allCases[index].rawValue.capitalized)
                        .fontWeight(.regular)
                        .font(.system(size: 21))
                        .foregroundStyle(Color(.white))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 60)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            
            if let prayerTimes = getPrayerTimes() {
                PrayerScheduleView(prayerTimes: prayerTimes, selectedPrayerIndex: selectedPrayerIndex)
                    .fontWeight(.semibold)
                    .font(.system(size: 34))
                    .foregroundStyle(Color(.green))

            } else {
                Text("Prayer times not available")
                    .fontWeight(.semibold)
                    .font(.system(size: 34))
                    .foregroundStyle(Color(.green))
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
        
        
    }
    
    func getPrayerTimes() -> PrayerTimes? {
        let province = locationManager.province
        let city = locationManager.city
        let currentDate = Date()
        print("Loading prayer times for \(currentDate), Province: \(province), City: \(city)")
        return loadPrayerTimes(for: currentDate, province: province, city: city)
    }
}

struct PrayerScheduleView: View {
    let prayerTimes: PrayerTimes
    let selectedPrayerIndex: Int
    
    init(prayerTimes: PrayerTimes, selectedPrayerIndex: Int) {
        self.prayerTimes = prayerTimes
        self.selectedPrayerIndex = selectedPrayerIndex
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            switch selectedPrayerIndex {
            case 0:
                Text("\(prayerTimes.fajr)")
            case 1:
                Text("\(prayerTimes.sunrise)")
            case 2:
                Text("\(prayerTimes.dhuhr)")
            case 3:
                Text("\(prayerTimes.asr)")
            case 4:
                Text("\(prayerTimes.maghrib)")
            case 5:
                Text("\(prayerTimes.isha)")
            default:
                Text("Unknown Prayer")
            }
        }
        .padding()
    }
}

enum Prayer: String, CaseIterable {
    case fajr, sunrise, dhuhr, asr, maghrib, isha
}

struct PickerPrayerTimesView_Previews: PreviewProvider {
    static var previews: some View {
        PickerPrayerTimesView()
    }
}

