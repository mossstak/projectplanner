//
//  NewTaskViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class NewTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {


    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskContributor: UITextField!
    @IBOutlet weak var notesView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var completionSlider: UISlider!
    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet weak var dateControl: UISegmentedControl!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    
    var changeTasks: Task?
    var VC: DetailViewController?

    var startDate = Date()
    var dueDate = Date()
    var relateProject: Project?


    override func viewDidLoad() {
        super.viewDidLoad()

        taskNameField.delegate = self
        taskContributor.delegate = self
        notesView.delegate = self

        self.preferredContentSize = CGSize(width: 750, height: 363)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        completionLabel.text = "50% completed"

        datePicker.maximumDate = nil

        if modifyVC {
            title = "Modify a task"
            addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: nil)
            if let task = changeTasks {
                setUpFor(task)
            }
        } else {
            title = "Add a task"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setUpFor(_ task: Task) {
        taskNameField.text = task.name
        taskContributor.text = task.contributor
        notesView.text = task.notes
        datePicker.date = task.startDate! as Date
        datePicker.minimumDate = nil
        datePicker.maximumDate = Date()
        startDate = task.startDate! as Date
        dueDate = task.dueDate! as Date
        completionSlider.value = Float(task.completion)
        completionLabel.text = "\(Int(task.completion))% complete"
        priorityControl.setTitle("Low", forSegmentAt: 0)
        priorityControl.setTitle("Medium", forSegmentAt: 1)
        priorityControl.setTitle("High", forSegmentAt: 2)
    }
    





    @IBAction func addButtonTouched(_ sender: UIBarButtonItem) {
        if taskNameField.text != "" && taskContributor.text != "" {
            if modifyVC {
                if let task = changeTasks {
                    saveModifications(forTask: task)
                }
            } else {
                saveNewTask()
            }
            self.dismiss(animated: true) {
                modifyVC = false
                self.VC?.tasks = self.VC?.fetchRelatedTasks()
                self.VC?.taskTableView.reloadData()
                self.VC?.setCompletionProgressValue()
            }
        }

    }

    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            modifyVC = false
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        completionLabel.text = "\(Int(sender.value))% complete"
    }

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            dueDate = datePicker.date
            datePicker.minimumDate = nil
            datePicker.maximumDate = Date()
            datePicker.date = startDate
        } else {
            startDate = datePicker.date
            datePicker.minimumDate = Date()
            datePicker.maximumDate = nil
            datePicker.date = dueDate
        }
    }

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        if dateControl.selectedSegmentIndex == 0 {
            startDate = datePicker.date
        } else {
            dueDate = datePicker.date
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
        
    }



    func saveNewTask() {
        if taskNameField.text != "" && taskContributor.text != "" {
            let addTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: showContext) as! Task
            
            addTask.taskID = String(Date.timeIntervalSinceReferenceDate)
            addTask.relatedProjectID = relateProject!.projectID
            addTask.completion = completionSlider.value
            addTask.name = taskNameField.text != "" ? taskNameField.text : "Task"
            addTask.contributor = taskContributor.text != "" ? taskContributor.text : "Contributor"
            addTask.notes = notesView.text
            addTask.dueDate = modified(Date: dueDate) as Date
            addTask.startDate = startDate as Date
            addTask.priority = priorityControl.titleForSegment(at: priorityControl.selectedSegmentIndex)!

            do {
                try showContext.save()
                if (addTask.completion < 100.0) {
                    createNotification(forTask: addTask)
                }
            } catch let error {
                showContext.rollback()
                print(error.localizedDescription)
            }
        }

    }

    func saveModifications(forTask: Task) {
        if taskNameField.text != "" && taskContributor.text != "" {
            changeTasks?.completion = completionSlider.value
            changeTasks?.name = taskNameField.text != "" ? taskNameField.text : "Task"
            changeTasks?.contributor = taskContributor.text != "" ? taskContributor.text : "Contributor"
            changeTasks?.notes = notesView.text
            changeTasks?.dueDate = modified(Date: dueDate) as Date
            changeTasks?.startDate = startDate as Date
            changeTasks?.priority = priorityControl.titleForSegment(at: priorityControl.selectedSegmentIndex)!

            do {
                try showContext.save()
                if !((changeTasks?.completion)! < Float(100.0)) {
                    notificationShown.removePendingNotificationRequests(withIdentifiers: [(changeTasks?.taskID!)!])
                } else {
                    modifyNotification(forTask: changeTasks!)
                }

            } catch let error {
                showContext.rollback()
                print(error.localizedDescription)
            }
        }

    }


    // Notification content
    
    func createNotification(forTask task: Task) {

        let NotificationContent = UNMutableNotificationContent()
        NotificationContent.title = task.name ?? "Task"
        NotificationContent.subtitle = task.contributor ?? "Contributor"
        NotificationContent.body = "remember to check your tasks!"
        NotificationContent.sound = UNNotificationSound.default

        var DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate! as Date)
        DateComponents.hour = 10
        DateComponents.minute = 01

        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents, repeats: false)
        let identifier = task.taskID

        let request = UNNotificationRequest(identifier: identifier!, content: NotificationContent, trigger: trigger)

        notificationShown.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Notification is created")
            }
        }
    }

    
    func modifyNotification(forTask task: Task) {

        notificationShown.getPendingNotificationRequests { (requests) in
            let filterRequest = requests.filter({ (request) -> Bool in
                return request.identifier == task.taskID
            })
            
            if let previousRequest = filterRequest.first {
                
                let contentRequest = previousRequest.content
                let identifier = previousRequest.identifier

                var DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate! as Date)
               
                DateComponents.hour = 15
                DateComponents.minute = 0

                let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents, repeats: false)

                let request = UNNotificationRequest(identifier: identifier, content: contentRequest, trigger: trigger)

                notificationShown.add(request) { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Notification is overwritten")
                    }
                }
            }
        }
    }


    func modified(Date: Date) -> Date {
        var dateCom = calendar.dateComponents([.year, .month, .day], from: Date)
        dateCom.hour = 10
        dateCom.minute = 00
        return calendar.date(from: dateCom)!
    }

}
