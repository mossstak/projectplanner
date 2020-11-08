//
//  AddProjectDateViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit

class AddProjectDateViewController: UIViewController {


    @IBOutlet weak var datePicker: UIDatePicker!



    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = CGSize(width: 320, height: 400)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        newCoursework?.dueDate = datePicker.date as NSDate
    }

}

   
