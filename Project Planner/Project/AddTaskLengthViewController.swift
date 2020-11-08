//
//  AddTaskLengthViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit

class AddTaskLengthViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var lengthLabel: UILabel!


    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = CGSize(width: 320, height: 400)

        stepper.value = 0
        stepper.stepValue = 1

        lengthLabel.text = "0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        newTask?.length = Float(stepper.value)
    }

*/
    // MARK: Actions

    @IBAction func stepperTouched(_ sender: UIStepper) {
        lengthLabel.text = String(sender.value)
    }
}
