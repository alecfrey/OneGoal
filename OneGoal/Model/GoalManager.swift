//
//  GoalManager.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import Foundation
import CoreData

class GoalManager: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    let container = NSPersistentContainer(name: "Stash")

    override init() {
        super.init()
        container.loadPersistentStores { _, _ in }
    }
}
