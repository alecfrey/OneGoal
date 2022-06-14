//
//  OneGoalViewModel.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import Foundation

class OneGoalViewModel: ObservableObject {
    @Published var goalArray: Array<Goal> = Array()

    func printNewGoal() {
        let index = goalArray.count - 1
        print("Goal: " + String(goalArray[index].description))
        print("Date: " + String(goalArray[index].date))
        print("isAccomplished: " + String(goalArray[index].isAccomplished))
        print("ID: " + String(goalArray[index].id))
    }
    
    func isTodaysGoalCreated() -> Bool {
        if (goalArray.isEmpty) { return false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let phoneDate = String(dateFormatter.string(from: Date()))
        
        if (goalArray[goalArray.count - 1].date == phoneDate) {
            return true
        } else {
            return false
        }
    }
    
    func newGalleryIndex(clickedForward: Bool, index: Int) -> Int {
        if clickedForward == true {
            if index < goalArray.count - 1 {
                return index + 1
            }
        } else if clickedForward == false {
            if index > goalArray.count - 1 {
                return index - 1
            }
        }
        return index
    }
}
