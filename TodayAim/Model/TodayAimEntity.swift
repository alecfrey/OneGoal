//
//  TodayAimEntity.swift
//  Today Aim
//
//  Created by Alec Frey on 6/6/22.
//

import Foundation
import SwiftUI
import CoreData

extension TodayAimEntity {
    convenience init(aimDescription: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.aimDescription = aimDescription
        self.date = Date()
        self.isAccomplished = false
        self.isFavorited = false
    }
    
    func dateFormatted() -> String {
        guard let date = self.date else {
            return ""
        }
        return DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
    }
    
    var wasCreatedToday: Bool {
        guard let date = self.date else {
            return false
        }
        return Calendar.current.isDateInToday(date)
    }
    
    var offsetFromCurrentDay: Int {
        let calendar = Calendar.current
        guard let date = self.date else {
            return 0
        }
        let aimDate = calendar.startOfDay(for: date)
        let todayDate = calendar.startOfDay(for: Date())
        return calendar.dateComponents([.day], from: todayDate, to: aimDate).day!
    }
    
    var wasNotAccomplished: Bool {
        return !isAccomplished && !wasCreatedToday
    }
}
    
