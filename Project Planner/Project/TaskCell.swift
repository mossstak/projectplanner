//
//  TaskCell.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit


class TaskCell: UITableViewCell {


    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var taskContributor: UILabel!
    @IBOutlet weak var taskTimeLeft: UILabel!
    @IBOutlet weak var taskCompleted: UILabel!
    @IBOutlet weak var taskReminderBtn: UIButton!
    @IBOutlet var taskProgressBar: progressViewBar!
    @IBOutlet weak var taskPriority: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setUp(with task: Task) {
        taskReminderBtn.isEnabled = true;
        taskName.text = task.name
        taskContributor.text = task.contributor
        taskTimeLeft.text = "\(getTaskTimeLeft(of: task)) days left"
        taskCompleted.text = "\(Int(task.completion))% Progress"
        taskProgressBar.checkProgress = task.completion / 100.0
        taskPriority.text = task.priority
    }

    func getTaskTimeLeft(of task: Task) -> Int {
        let interval = calendar.dateComponents([.day], from: Date(), to: task.dueDate! as Date)
        if interval.day! >= 0 {
            return interval.day!
        }
        return 0
    }


    

}
