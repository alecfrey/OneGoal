//
//  GoalEntity.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import Foundation
import SwiftUI
import CoreData

/*
struct Goal: Identifiable {
    let id: UUID
    let description: String
    let date: String
    private let rawDate: Date
    var isAccomplished: Bool
    var timeAccomplished: String?
    var wasNotAccomplished: Bool
    var isFavorited: Bool
    
    init(description: String) {
        self.description = description
        self.isAccomplished = false
        self.isFavorited = false
        self.wasNotAccomplished = false
        self.id = UUID()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.date = dateFormatter.string(from: Date())
        self.rawDate = Date()
    }
*/

extension GoalEntity {
    convenience init(goalDescription: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.goalDescription = goalDescription
        self.date = Date()
        self.isAccomplished = false
        self.isFavorited = false
        self.wasNotAccomplished = false
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
}
    
