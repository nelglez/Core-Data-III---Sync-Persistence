//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Julian A. Fordyce on 6/3/19.
//  Copyright © 2019 Glas Labs. All rights reserved.
//

import Foundation
import CoreData


enum TaskPriority: String, Codable {
    case low
    case normal
    case high
    case critical
    
    static var allPriorities: [TaskPriority] {
        return [.low, .normal, .high, .critical]
    }
}

extension Task {
    convenience init(name: String, notes: String? = nil, priority: TaskPriority = .normal, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
        self.identifier = identifier
    }
    //This allows us to turn a taskRepresentation into a task.
    convenience init(taskRepresentation: TaskRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(name: taskRepresentation.name, notes: taskRepresentation.notes, priority: taskRepresentation.priority, identifier: taskRepresentation.identifier, context: context)
    }
    
    //This allows us to turn a task into a taskRepresentation.
    var taskRepresentation: TaskRepresentation? {
        guard let name = name, let priorityString = priority, let priority = TaskPriority(rawValue: priorityString) else { return nil }
        
       // if the old data does not have an identifier, we need to create one
        if identifier == nil {
            identifier = UUID()
        }
        
        return TaskRepresentation(identifier: identifier!, name: name, notes: notes, priority: priority)
    }
    
}
