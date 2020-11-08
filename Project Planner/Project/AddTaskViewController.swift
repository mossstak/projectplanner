//
//  AddTaskViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController {


    @IBOutlet weak var taskNameField: UITextField!

    var relatedCoursework: Coursework!



    override func viewDidLoad() {
        super.viewDidLoad()

        newTask = Task()

        self.preferredContentSize = CGSize(width: 320, height: 400)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }



    @IBAction func addButtonTouched(_ sender: UIBarButtonItem) {
        save()
        self.dismiss(animated: true) {
            newTask = nil
        }
    }

    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            newTask = nil
        }
    }



    func updateTaskData() {
        newTask?.name = taskNameField.text
        newTask?.relatedCourseworkID = relatedCoursework.courseworkID
    }

    func save() {
        do {
            var newEntity = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context) as! Task
            newEntity = newTask!
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }



}
