//
//  TasksDetailViewController.swift
//  Tasks
//
//  Created by Julian A. Fordyce on 6/3/19.
//  Copyright © 2019 Glas Labs. All rights reserved.
//

import UIKit

class TasksDetailViewController: UIViewController {
    
    
    //   MARK: - Properties
    
    var taskController: TaskController!
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()

    }
    
    
    private func updateViews() {
        guard isViewLoaded else {
            return
        }
        
        title = task?.name ?? "Create Task"
        nameTextField.text = task?.name
        notesTextView.text = task?.notes
        
        let priority: TaskPriority
        if let taskPriority = task?.priority {
            priority = TaskPriority(rawValue: taskPriority)!
        } else {
            priority = .normal
        }
        
        priorityControl.selectedSegmentIndex = TaskPriority.allPriorities.firstIndex(of: priority)!
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func saveTask(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        let notes = notesTextView.text
        
        let priorityIndex = priorityControl.selectedSegmentIndex
        let priority = TaskPriority.allPriorities[priorityIndex]
        
        if let task = task {
            task.name = name
            task.priority = priority.rawValue
            task.notes = notes
            taskController.put(task: task)//If it exists already
        } else {
            let task = Task(name: name, notes: notes, priority: priority)
            taskController.put(task: task)//Create one if it doesnt exist
        }
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
        navigationController?.popViewController(animated: true)
    }
    

    @IBOutlet weak var priorityControl: UISegmentedControl!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    

}
