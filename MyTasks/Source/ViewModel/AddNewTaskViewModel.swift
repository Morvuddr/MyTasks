//
//  AddNewTaskViewModel.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import RxSwift
import RxCocoa

class AddNewTaskViewModel {

    // MARK: - Properties
    public let nameSubject = BehaviorRelay<String>(value: "")
    public let descriptionSubject = BehaviorRelay<String>(value: "")
    public let prioritySubject = BehaviorRelay<TaskPriority>(value: .low)
    public let actionButtonIsEnabled = BehaviorRelay<Bool>(value: false)
    public let shoudRemind = BehaviorRelay<Bool>(value: false)
    public let dateSubject = BehaviorRelay<Date>(value: Date())
    public let isEditing = BehaviorSubject<Bool>(value: false)

    private var taskID: String? = nil
    private var taskIsChecked: Bool = false
    private let dataStore: TasksDataStore
    private let bag = DisposeBag()


    // MARK: - Methods

    init(taskID: String?, dataStore: TasksDataStore) {
        self.dataStore = dataStore
        self.taskID = taskID

        dateSubject.accept(getRemindDate(from: Date()))
        if let taskID = taskID, let task = dataStore.getTask(by: taskID) {
            nameSubject.accept(task.name)
            descriptionSubject.accept(task.shortDescription)
            prioritySubject.accept(task.priority)
            shoudRemind.accept(task.shouldRemind)
            dateSubject.accept(task.date)
            taskIsChecked = task.checked
            isEditing.onNext(true)
        }
        
        Observable.combineLatest(nameSubject, descriptionSubject)
            .subscribe(onNext: { [weak self] (name, description) in
                if !name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty  && !description.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    self?.actionButtonIsEnabled.accept(true)
                } else {
                    self?.actionButtonIsEnabled.accept(false)
                }
            }).disposed(by: bag)

    }

    public func save() {
        let newTask = Task(id: taskID,
                           name: nameSubject.value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                           description: descriptionSubject.value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                           priority: prioritySubject.value,
                           shouldRemind: shoudRemind.value,
                           date: dateSubject.value,
                           checked: taskIsChecked)
        dataStore.add(task: newTask)
        isEditing.onCompleted()
    }

}
