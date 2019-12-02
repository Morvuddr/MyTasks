//
//  Task.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import RealmSwift
import RxDataSources

enum TaskPriority: Int {
    case low = 1
    case medium = 2
    case high = 3
}

class Task: Object, IdentifiableType {
    @objc dynamic var taskID: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var shortDescription: String = ""
    @objc private dynamic var privatePriority: Int = TaskPriority.low.rawValue
    var priority: TaskPriority {
        get { return TaskPriority(rawValue: privatePriority)! }
        set { privatePriority = newValue.rawValue }
    }

    override class func primaryKey() -> String? {
        return "taskID"
    }

    var identity: String {
        return taskID
    }

    convenience init(id: String? = nil, name: String, description: String, priority: TaskPriority) {
        self.init()
        self.taskID = id ?? UUID().uuidString
        self.name = name
        self.shortDescription = description
        self.priority = priority
    }
}
