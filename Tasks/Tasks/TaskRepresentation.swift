//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Nelson Gonzalez on 6/5/19.
//  Copyright © 2019 Glas Labs. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable, Equatable {
    var identifier: UUID //All tasks on the server must have an identifier. So no optional
    var name: String
    var notes: String?
    var priority: TaskPriority
}
