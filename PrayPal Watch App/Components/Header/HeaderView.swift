//
//  HeaderView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct HeaderView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            HStack {
                if let status = locationManager.authorizationStatus {
                    switch status {
                    case .notDetermined:
                        Text("Requesting location access...")
                            .fontWeight(.regular)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: 0xA9A9A9))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 90, alignment: .leading)
                    case .restricted, .denied:
                        Text("Location access denied.")
                            .fontWeight(.regular)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: 0xA9A9A9))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 90, alignment: .leading)
                    case .authorizedAlways, .authorizedWhenInUse:
                        VStack {
                            Text("\(locationManager.city)")
                                .fontWeight(.regular)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: 0xA9A9A9))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: 90, alignment: .leading)
                        }
                    default:
                        Text("Unexpected status")
                            .fontWeight(.regular)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: 0xA9A9A9))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 90, alignment: .leading)
                    }
                } else {
                    Text("Checking location authorization status...")
                        .fontWeight(.regular)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: 0xA9A9A9))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 90, alignment: .leading)
                }
            }
            
            }
        }
}

#Preview {
    HeaderView()
}
