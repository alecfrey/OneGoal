//
//  Goal.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import Foundation
import SwiftUI

struct Goal: Identifiable {
    let id: String
    let description: String
    let date: String
    private let rawDate: Date
    var isAccomplished: Bool
    var timeAccomplished: String?
    var wasNotAccomplished: Bool
    var isFavorited: Bool
    
    //var comment: String?
    //var image: Image?
    
    init(description: String) {
        self.description = description
        self.isAccomplished = false
        self.isFavorited = false
        self.wasNotAccomplished = false
        self.id = UUID().uuidString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.date = dateFormatter.string(from: Date())
        self.rawDate = Date()
    }
    
    func dateFormatted() -> String {
        return DateFormatter.localizedString(from: self.rawDate, dateStyle: .long, timeStyle: .none)
        
        /*
        let month = Int(date.prefix(2))
        let day = date[date.index(date.startIndex, offsetBy: 3)..<date.index(date.endIndex, offsetBy: -5)]
        let year = date[date.index(date.startIndex, offsetBy: 6)..<date.index(date.endIndex, offsetBy: -0)]
        
        if (month == 01) {
            return "January " + day + ", " + year
        } else if (month == 02) {
            return "February " + day + ", " + year
        } else if (month == 03) {
            return "March " + day + ", " + year
        } else if (month == 04) {
            return "April " + day + ", " + year
        } else if (month == 05) {
            return "May " + day + ", " + year
        } else if (month == 06) {
            return "June " + day + ", " + year
        } else if (month == 07) {
            return "July " + day + ", " + year
        } else if (month == 08) {
            return "August " + day + ", " + year
        } else if (month == 09) {
            return "September " + day + ", " + year
        } else if (month == 10) {
            return "October " + day + ", " + year
        } else if (month == 11) {
            return "November " + day + ", " + year
        } else if (month == 12) {
            return "December " + day + ", " + year
        } else {
            return ""
        }
         */
    }
    
    var goalWasCreatedToday: Bool {
        Calendar.current.isDateInToday(self.rawDate)
    }
    
//    static func == (lhs: Goal, rhs: Goal) -> Bool {
//        (lhs.id == rhs.id)
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(self.id)
//    }
}
    
    
