//
//  DetailViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit
import CoreData


class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {


    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var projectLeaderLabel: UILabel!
    @IBOutlet weak var projectDate: UILabel!
    
    
    @IBOutlet var projectPriorityView: UILabel!
    @IBOutlet weak var timeLeftView: UILabel!
    @IBOutlet weak var projectCompletedView: UILabel!
    
    @IBOutlet weak var descriptionView: UITextView!
    
    
    
    @IBOutlet var projectCompletedBar: progressViewBar!
    @IBOutlet var projectTimeBar: progressViewBar!
    @IBOutlet weak var taskTableView: UITableView!

    @IBOutlet weak var projectEditBtn: UIBarButtonItem!
    @IBOutlet weak var projectReminderBtn: UIBarButtonItem!
    @IBOutlet weak var taskAddBtn: UIBarButtonItem!

    var myItems: Project?

    var tasks: [Task]?

   
    func configureView() {

        if let items = myItems {

           
            previousProjectID = Int(items.projectID)
            UserDefaults.standard.set(previousProjectID, forKey: "lastSeenProjectID")

            projectEditBtn.isEnabled = true
            projectReminderBtn.isEnabled = true
            taskAddBtn.isEnabled = true

            tasks = fetchRelatedTasks()

            self.title = items.projectName
            
            projectNameLabel.text = items.projectName
            projectLeaderLabel.text = items.projectLeader
            projectDate.text = formateDate.string(from: items.dueDate! as Date)
            descriptionView.text = items.notes
            projectPriorityView.text = items.priority!

            taskTableView.reloadData()
            setTimeRemainingProgressValue()
            setCompletionProgressValue()
        }
            
        else {
            title = nil

            projectEditBtn.isEnabled = false
            projectReminderBtn.isEnabled = false
            taskAddBtn.isEnabled = false

            
            let view = UIView()
            view.frame = super.view.frame
            view.backgroundColor = UIColor.white
            self.view.addSubview(view)

           self.title = "No project selected"
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "TaskCell")

        taskTableView.delegate = self
        taskTableView.dataSource = self

        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks != nil ? tasks!.count : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        modifyVC = true

        let popver = UIStoryboard(name: "AddTask", bundle: nil).instantiateViewController(withIdentifier: "AddTaskNavController")
        popver.modalPresentationStyle = .popover
        popver.preferredContentSize = CGSize(width: 750, height: 363)
        ((popver as! UINavigationController).viewControllers.first! as! NewTaskViewController).changeTasks = tasks?[indexPath.row]
        
        ((popver as! UINavigationController).viewControllers.first! as! NewTaskViewController).VC = self

     
        let popovPresentation = popver.popoverPresentationController
        popovPresentation?.delegate = self as UIPopoverPresentationControllerDelegate
        popovPresentation?.permittedArrowDirections = .any
        popovPresentation?.sourceView = tableView.cellForRow(at: indexPath)
        popovPresentation?.sourceRect = CGRect(x: 1, y: 1, width: 702, height: 50)

        present(popver, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellt = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell

        if let task = tasks?[indexPath.row] {
            cellt?.setUp(with: task)
            
            (cellt?.taskReminderBtn as! subTabButtons).indexPath = indexPath
            cellt?.taskReminderBtn.addTarget(self, action: #selector(self.projectReminderBtnTouched(sender:)), for: .touchUpInside)
        }

        return cellt!
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            showContext.delete((tasks?[indexPath.row])!)

            
            notificationShown.removePendingNotificationRequests(withIdentifiers: [(tasks?[indexPath.row])!.taskID!])

            do {
                try showContext.save()
            } catch {
                let nError = error as NSError
                fatalError("Unresolved error \(nError), \(nError.userInfo)")
            }
            tasks = fetchRelatedTasks()
            taskTableView.reloadData()
        }

    }
    func fetchRelatedTasks() -> [Task]? {

        if let items1 = myItems {

            do {
                let detailsID = items1.projectID
                let getRequest = NSFetchRequest<Task>(entityName: "Task")
                getRequest.predicate = NSPredicate(format: "relatedProjectID == %d", detailsID)
                let getTasks = try showContext.fetch(getRequest)
                return getTasks
            } catch let error {
                print(error.localizedDescription)
            }
        }

        return nil
    }

    @IBAction func projectEditBtnTouched(_ sender: UIBarButtonItem) {

        modifyVC = true

        let popver = UIStoryboard(name: "AddProject", bundle: nil).instantiateViewController(withIdentifier: "AddProjectNavController")
        popver.modalPresentationStyle = .popover
        popver.preferredContentSize = CGSize(width: 750, height: 363)
        ((popver as! UINavigationController).viewControllers.first! as! NewProjectViewController).modifiedProject = myItems
        
        ((popver as! UINavigationController).viewControllers.first! as! NewProjectViewController).VC = self

        let popverPresentation = popver.popoverPresentationController
        popverPresentation?.delegate = self as UIPopoverPresentationControllerDelegate
        popverPresentation?.permittedArrowDirections = .any
        popverPresentation?.barButtonItem = projectEditBtn
        popverPresentation?.sourceRect = CGRect(x: 1, y: 1, width: 1, height: 1)

        present(popver, animated: true, completion: nil)
    }


    @IBAction func setProjectReminderButtonTouched(_ sender: UIBarButtonItem) {
        addReminderFor(project: myItems!)
    }


    
    @objc func projectReminderBtnTouched(sender: subTabButtons) {
        if let task = tasks?[(sender.indexPath?.row)!] {
            performSegue(withIdentifier: "addReminderForTask", sender: task)
        }
    }

        func addReminderFor(project: Project) {
        performSegue(withIdentifier: "addReminderForProject", sender: project)
    }

// the segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "addTask" {
            
            let destination = (segue.destination as! UINavigationController).viewControllers.first as! NewTaskViewController
            destination.relateProject = myItems
            
            destination.VC = self
        }

        
        else if segue.identifier == "addReminderForProject" {
            let popver = (segue.destination as! UINavigationController).viewControllers.first as! AddReminderViewController
            popver.projectReminder = sender as? Project
            popver.taskReminder = nil
        }

        
        else if segue.identifier == "addReminderForTask" {
            let popver = (segue.destination as! UINavigationController).viewControllers.first as! AddReminderViewController
            popver.projectReminder = nil
            popver.taskReminder = sender as? Task
        }
    }

    // Time Remaining

    func setTimeRemainingProgressValue() {
        let timePassedComponent = calendar.dateComponents([.day], from: (myItems?.startDate)! as Date, to: Date())
        let totalTimeComponent = calendar.dateComponents([.day], from: (myItems?.startDate)! as Date, to: (myItems?.dueDate)! as Date)
        let timeRemainingValue = Float(timePassedComponent.day!) / Float(totalTimeComponent.day!)
        projectTimeBar.checkProgress -= timeRemainingValue
        timeLeftView.text = "\(getTimeRemaining()) days remaining"
    }

    
    func setCompletionProgressValue() {
        var completedProgress: Float = 0.0
        var numberOfTasks: Float = 0.0

        if let tasks = tasks {
            numberOfTasks = Float(tasks.count)
            for task in tasks {
                let taskCompletion = task.completion / 100.0
                completedProgress += taskCompletion
            }
            completedProgress = numberOfTasks != 0.0 ? completedProgress/numberOfTasks : 0.0
            projectCompletedBar.checkProgress = completedProgress
            projectCompletedView.text = "\(Int(completedProgress * 100))% completed"
            return
        }

        projectCompletedBar.checkProgress = 1.0
        projectCompletedView.text = "100% completed"
        return
    }

    func getTimeRemaining() -> Int {
        let intervalt = calendar.dateComponents([.day], from: Date(), to: myItems?.dueDate! as! Date)
        if intervalt.day! >= 0 {
            return intervalt.day!
        }
        return 0
    }

}

