//
//  NavigationControllerViewModel.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import RxSwift


public enum CurrentView {

    case tasks
    case addNewTask(String?)

}

class NavigationControllerViewModel {

    // MARK: - Properties
    public var view: Observable<CurrentView> { return _view.asObservable() }
    private let _view = BehaviorSubject<CurrentView>(value: .tasks)

    // MARK: - Methods
    public init() {}

    public func navigateToAddNewTaskView(taskID: String?) {
        _view.onNext(.addNewTask(taskID))
    }

}
