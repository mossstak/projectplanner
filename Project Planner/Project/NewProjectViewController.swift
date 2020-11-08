//
//  NewProjectViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class NewProjectViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {


    @IBOutlet weak var projectNameField: UITextField!
    @IBOutlet weak var projectLeaderField: UITextField!
    @IBOutlet weak var notesView: UITextView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    

    var modifiedProject: Project?
    var VC: UIViewController?
    var dateBeforeModification: Date?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectNameField.delegate = self
        projectLeaderField.delegate = self
        notesView.delegate = self

        self.preferredContentSize = CGSize(width: 750, height: 363)

        priorityControl.selectedSegmentIndex = 0;

        dueDatePicker.minimumDate = Date()

        if modifyVC {
            title = "Change project"
            addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: nil)
            if let coursework = modifiedProject {
                setUpFor(coursework)
            }
        } else {
            title = "Add project"
            addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setUpFor(_ P: Project) {
        projectNameField.text = P.projectName
        projectLeaderField.text = P.projectLeader
        priorityControl.setTitle("Low", forSegmentAt: 0)
        priorityControl.setTitle("Medium", forSegmentAt: 1)
        priorityControl.setTitle("High", forSegmentAt: 2)
        notesView.text = P.notes
        dueDatePicker.date = P.dueDate! as Date
        dateBeforeModification = P.dueDate! as Date
    }
    

    @IBAction func addButtonTouched(_ sender: UIBarButtonItem) {
        if projectNameField.text != "" && projectLeaderField.text != ""{
            if modifyVC {
                if let project = modifiedProject {
                    saveModifications(forProject: project)
                }
            } else {
                saveNewProject()
            }
            modifyVC = false
            self.dismiss(animated: true) {

                
                if let parent = self.VC as? DetailViewController {
                    parent.myItems = self.modifiedProject
                    parent.configureView()

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: reloadMasterNotificationKey), object: nil)
                }


                else if let parent = self.VC as? MasterViewController {
                    parent.getProjects = parent.fetchProjects()
                    parent.tableView.reloadData()
                }
            }
        }

    }

    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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


    
    func saveNewProject() {
            let newP = NSEntityDescription.insertNewObject(forEntityName: "Project", into: showContext) as! Project
            newP.projectID = Int64(Date.timeIntervalSinceReferenceDate)
            newP.projectName = projectNameField.text ?? "Project"
            newP.projectLeader = projectLeaderField.text
            newP.notes = notesView.text
            newP.dueDate = modified(date: dueDatePicker.date) as Date
            newP.startDate = Date() as Date
            newP.priority = priorityControl.titleForSegment(at: priorityControl.selectedSegmentIndex)!
            do {
                try showContext.save()
                createCalendarEvent()
            } catch let error {
                showContext.rollback()
                print(error.localizedDescription)
            }

    }

    func saveModifications(forProject Project: Project) {
            modifiedProject?.projectName = projectNameField.text
            modifiedProject?.projectLeader = projectLeaderField.text
            modifiedProject?.notes = notesView.text
            modifiedProject?.dueDate = modified(date: dueDatePicker.date) as Date
            modifiedProject?.startDate = Date() as Date
            modifiedProject?.priority = priorityControl.titleForSegment(at: priorityControl.selectedSegmentIndex)!
            do {
                try showContext.save()
                if dateBeforeModification != modified(date: dueDatePicker.date) {
                    createCalendarEvent()
                }
            } catch let error {
                showContext.rollback()
                print(error.localizedDescription)
            }
    }


    // Store Event

    func createCalendarEvent() {
        let eventS: EKEventStore = EKEventStore()

        eventS.requestAccess(to: .event) { (granted, error) in
            if granted && (error == nil) {
                let eventR: EKEvent = EKEvent(eventStore: eventS)
                eventR.title = self.projectNameField.text ?? "Project"
                eventR.title = self.projectLeaderField.text
                eventR.isAllDay = true
                eventR.startDate = self.dueDatePicker.date
                eventR.endDate = self.dueDatePicker.date
                eventR.notes = "Due Date of the Project"
                eventR.calendar = eventS.defaultCalendarForNewEvents
                eventR.addAlarm(EKAlarm.init(relativeOffset: -86400.0))
                do {
                    try eventS.save(eventR, span: .thisEvent)
                    print("event saved")
                } catch let error {
                    print(error.localizedDescription)
                }
            } else {
                print("Access not granted or an error occured")
            }
        }
    }



    func modified(date: Date) -> Date {
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 10
        dateComponents.minute = 00
        return calendar.date(from: dateComponents)!
    }



}
