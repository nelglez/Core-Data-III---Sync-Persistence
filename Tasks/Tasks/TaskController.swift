//
//  TaskController.swift
//  Tasks
//
//  Created by Nelson Gonzalez on 6/5/19.
//  Copyright © 2019 Glas Labs. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!

class TaskController {
    
    init() {
        fetchTasksFromServer()
    }
    
    typealias CompletionHandler = (Error?) -> Void
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = {_ in}) {//allows it to be optional.
        let requestUrl = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestUrl) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let taskRepresentationDict = try JSONDecoder().decode([String: TaskRepresentation].self, from: data)
                    let taskRepresentations = Array(taskRepresentationDict.values)
                    
                    //Do they all have an ID
                    for taskRep in taskRepresentations {
                        let uuid = taskRep.identifier
                        if let task = self.task(forUUID: uuid) {
                            //We already have a local task for this so we can update it
                            self.update(task: task, with: taskRep)
                            
                        } else {
                            //We need to create a new task in core data
                            let _ = Task(taskRepresentation: taskRep)
                        }
                    }
                    
                    //Save changes to disk
                    
                    let moc = CoreDataStack.shared.mainContext
                    try moc.save()
                    
                } catch {
                    NSLog("Error decoding task: \(error)")
                    completion(error)
                    return
                }
                
                completion(nil)
            }
            
        }.resume()
        
    }
    
    //This allows us to check if a task with an particular id exists so that it shows only once and no duplicates
    
    private func task(forUUID uuid: UUID) -> Task? {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)//identifier == uuid
        
        let moc = CoreDataStack.shared.mainContext
        
        return (try? moc.fetch(fetchRequest))?.first //get the first id
        
    }
    
    //I already have this task, just check to see if its been updated.
    func update(task: Task, with representation: TaskRepresentation) {
        task.name = representation.name
        task.notes = representation.notes
        task.priority = representation.priority.rawValue
    }
    
    func put(task: Task, completion: @escaping CompletionHandler = {_ in}) {
        let uuid = task.identifier ?? UUID() //Does it have an id, if not create a new ID
        task.identifier = uuid
        
        let requestUrl = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = task.taskRepresentation else { throw NSError() }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error putting task to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            
        }.resume()
        
    }
    
}
