//
//  NextPrayerView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct NextPrayerView: View {
    var body: some View {
        VStack {
            HStack {
                HeaderView()
                Spacer()
            }
            Spacer()
            NextPrayerTimeView()
            Spacer()
            FooterView()
        }
        .padding(.top, 12)
        .padding(.bottom, 10)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .ignoresSafeArea()
    }
}

#Preview {
    NextPrayerView()
}
