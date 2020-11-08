//
//  ProjectCell.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {


    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectDueDate: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    func setUp(with project: Project) {
        projectName.text = project.projectName
        projectDueDate.text = formateDate.string(from: project.dueDate! as Date)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
