//
//  TaskTableViewCell.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: - Properties

    @IBOutlet weak var shadowView: ShadowView! {
        didSet {
            shadowView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var backgroundTaskView: UIView! {
        didSet {
             backgroundTaskView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priorityView: UIView!

    public var taskID: String!

    // MARK: - Methods
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    public func setup(task: Task) {
        taskID = task.taskID
        nameLabel.text = task.name
        descriptionLabel.text = task.shortDescription
        switch task.priority {
        case .low:
            priorityView.backgroundColor = .green
        case .medium:
            priorityView.backgroundColor = .yellow
        case .high:
            priorityView.backgroundColor = .red
        }
    }

}
