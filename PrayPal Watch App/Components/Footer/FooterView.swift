//
//  FooterView.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import SwiftUI

struct FooterView: View {
    @StateObject private var currentDate = FooterDateManager()
    
    var body: some View {
        Text("Kemenag")
            .fontWeight(.thin)
            .font(.system(size: 12))
            .foregroundStyle(Color(hex: 0xA9A9A9))
        Text(currentDate.getCurrentDateString())
            .fontWeight(.light)
            .font(.system(size: 14))
            .foregroundStyle(Color(hex: 0xA9A9A9))
    }
}

#Preview {
    FooterView()
}
