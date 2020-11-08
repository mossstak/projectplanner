//
//  AddReminderViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit
import EventKit

class AddReminderViewController: UIViewController {


    @IBOutlet weak var datePicker: UIDatePicker!

    
    var taskReminder: Task?
    var projectReminder: Project?


    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = CGSize(width: 320, height: 280)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addButtonTouched(_ sender: UIBarButtonItem) {
        if let task = taskReminder {
            createEvent(named: task.name)
            createEvent(named: task.contributor)
        } else if let project = projectReminder {
            createEvent(named: project.projectName)
            createEvent(named: project.projectLeader)
        }
        self.dismiss(animated: true, completion: nil)
    }



    func createEvent(named name: String?) {
        let eStore: EKEventStore = EKEventStore()

        eStore.requestAccess(to: .reminder) { (granted, error) in
            if granted && (error == nil) {
                let reminder: EKReminder = EKReminder(eventStore: eStore)
                reminder.title = name ?? "Title"
                reminder.calendar = eStore.defaultCalendarForNewReminders()
                let dueDateComponents = calendar.dateComponents([.year,
                                                                 .month,
                                                                 .day,
                                                                 .hour,
                                                                 .minute], from: self.datePicker.date)
                reminder.dueDateComponents = dueDateComponents
                do {
                    try eStore.save(reminder, commit: true)
                    print("Reminder saved")
                } catch let error {
                    print(error.localizedDescription)
                }
            } else {
                print("error, Try Again")
            }
        }
    }

}
