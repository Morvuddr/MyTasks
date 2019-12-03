//
//  TasksViewModel.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm

class TasksViewModel {

    // MARK: - Properties
    private let bag = DisposeBag()

    public var tasks: Observable<[Task]> { return _tasks.asObservable() }
    private let _tasks = BehaviorRelay<[Task]>(value: [])
    public var changeset: Observable<RealmChangeset?> { return _changeset.asObservable() }
    private let _changeset = BehaviorRelay<RealmChangeset?>(value: nil)

    public let openAddNewTaskView = PublishSubject<String?>()

    private let dataStore: TasksDataStore
    // MARK: - Mathods
    init(dataStore: TasksDataStore, navigationControllerViewModel: NavigationControllerViewModel) {
        self.dataStore = dataStore
        let data = dataStore.getTasks().share()

        data.subscribe(onNext: { [weak self] (tasks,_) in
            guard let sself = self else { return }
            sself._tasks.accept(tasks)
        }).disposed(by: bag)

        data.subscribe(onNext: { [weak self] (_,changeset) in
            guard let sself = self else { return }
            sself._changeset.accept(changeset)
        }).disposed(by: bag)


        openAddNewTaskView.subscribe(onNext: { taskID in
            navigationControllerViewModel.navigateToAddNewTaskView(taskID: taskID)
        }).disposed(by: bag)
    }

    public func deleteTask(taskID: String) {
        dataStore.delete(taskID: taskID)
    }

    public func checkTask(by taskID: String) {
        dataStore.check(taskID: taskID)
    }

}
