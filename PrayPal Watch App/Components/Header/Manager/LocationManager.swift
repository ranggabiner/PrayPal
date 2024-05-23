//
//  LocationManager.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var province: String = "Unknown"
    @Published var city: String = "Unknown"
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            // Handle the case where permission is not granted
            province = "Permission not granted"
            city = ""
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Error reverse geocoding location: \(error.localizedDescription)")
                    return
                }
                if let placemark = placemarks?.first {
                    self.province = placemark.administrativeArea ?? "Unknown"
                    self.city = placemark.locality ?? "Unknown"
                }
            }
            locationManager.stopUpdatingLocation()
        }
    }
}

extension LocationManager {
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
