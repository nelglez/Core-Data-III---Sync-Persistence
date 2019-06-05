//
//  CoreDataStack.swift
//  Tasks
//
//  Created by Julian A. Fordyce on 6/3/19.
//  Copyright © 2019 Glas Labs. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer =  {
        let container = NSPersistentContainer(name: "Tasks")
        container.loadPersistentStores { (_, error) in
            
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
            
        }
        
        return container
    }()
   
}
