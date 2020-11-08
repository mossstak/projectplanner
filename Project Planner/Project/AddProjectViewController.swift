//
//  AddProjectViewController.swift
//  Project
//
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit

class AddProjectDescriptViewController: UIViewController {
    
    
    @IBOutlet weak var descriptionView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 320, height: 400)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        newCoursework?.notes = descriptionView.text
    }
    
}

import UIKit
import CoreData




class AddCourseworkViewController: UIViewController {


    @IBOutlet weak var courseworkNameField: UITextField!
    @IBOutlet weak var moduleNameField: UITextField!
    @IBOutlet weak var levelControl: UISegmentedControl!
    @IBOutlet weak var weightSlider: UISlider!
    @IBOutlet weak var markSlider: UISlider!
    @IBOutlet weak var addButton: UIBarButtonItem!

    var selectedLevel: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = CGSize(width: 320, height: 400)

        guard newCoursework != nil else {
            newCoursework = Coursework()
            return
        }

        addButton.isEnabled = false
        levelControl.selectedSegmentIndex = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) { 
            newCoursework = nil
        }
    }

    @IBAction func addButtonTouched(_ sender: UIBarButtonItem) {
        save()
        self.dismiss(animated: true) { 
            newCoursework = nil
        }
    }

    @IBAction func levelControlValueChanged(_ sender: UISegmentedControl) {
        selectedLevel = Int64(sender.titleForSegment(at: sender.selectedSegmentIndex)!)!
    }


    func save() {
        newCoursework?.courseworkID = Int64(Date.timeIntervalSinceReferenceDate)
        do {
            var newEntity = NSEntityDescription.insertNewObject(forEntityName: "Coursework", into: context)
            newEntity = newCoursework!
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }



}
