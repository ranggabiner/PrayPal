//
//  FooterDataManager.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 23/05/24.
//

import Foundation
import Combine

class FooterDateManager: ObservableObject {
    @Published var currentDate: String = ""

    func getCurrentDateString() -> String {
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: currentDate)
        }
}
