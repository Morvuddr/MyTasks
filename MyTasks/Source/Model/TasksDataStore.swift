//
//  TaskModel.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import RxSwift
import RealmSwift
import RxRealm

class TasksDataStore {

    lazy var realm = try! Realm()

    let mock = [Task(name: "Задача 1", description: "Давно выяснено, что при оценке дизайна и композиции", priority: .low),
                Task(name: "Задача 2", description: "Давно выяснено, что при оценке дизайна и композиции читаемый текст мешает сосредоточиться.", priority: .medium),
                Task(name: "Задача 3", description: "Давно выяснено, что при оценке дизайна и композиции читаемый текст мешает сосредоточиться. Lorem Ipsum используют потому, что тот обеспечивает более утонченный вкус и все такое", priority: .high)]

    func getTasks() -> Observable<([Task], RealmChangeset?)> {
        return Observable.arrayWithChangeset(from: realm.objects(Task.self))
        //return Observable.array(from: realm.objects(Task.self))
        //return Observable.of(mock)
    }

    func getTask(by taskID: String) -> Task? {
        return realm.object(ofType: Task.self, forPrimaryKey: taskID)
    }

    func add(task: Task) {
        
        do {
            try realm.write {
                realm.add(task, update: .modified)
                scheduleNotification(for: task)
            }
        } catch (let error){
            print(error.localizedDescription)
        }

    }

    func delete(taskID: String) {
        do {
            guard let deletingTask = realm.object(ofType: Task.self, forPrimaryKey: taskID) else { return }
            try realm.write {
                realm.delete(deletingTask)
                removeNotification(for: taskID)
            }
        } catch (let error){
            print(error.localizedDescription)
        }
    }

    func check(taskID: String) {
        do {
            guard let task = realm.object(ofType: Task.self, forPrimaryKey: taskID) else { return }
            try realm.write {
                task.checked = !task.checked
                scheduleNotification(for: task)
            }
        } catch (let error){
            print(error.localizedDescription)
        }
    }

}

