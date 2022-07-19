//
//  GoalEntity.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import Foundation
import SwiftUI
import CoreData

extension GoalEntity {
    convenience init(goalDescription: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.goalDescription = goalDescription
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
    
    var goalWasCreatedToday: Bool {
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
        let goalDate = calendar.startOfDay(for: date)
        let todayDate = calendar.startOfDay(for: Date())
        return calendar.dateComponents([.day], from: todayDate, to: goalDate).day!
    }
    
    var wasNotAccomplished: Bool {
        return !isAccomplished && !goalWasCreatedToday
    }
}
    
