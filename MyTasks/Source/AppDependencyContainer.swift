//
//  AppDependencyContainer.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import UIKit

class AppDependencyContainer {

    let sharedNavigationControllerViewModel = NavigationControllerViewModel()

    public func makeRootViewController() -> RootViewController {
        let navigationController = makeNavigationController()
        return RootViewController(childVC: navigationController)
    }

    func makeNavigationController() -> NavigationController {
        let tasksVC = makeTasksViewController()
        let addNewTaskVC = { (taskID) in
            return self.makeAddNewTaskViewController(taskID: taskID)
        }
        return NavigationController.create(with: sharedNavigationControllerViewModel, tasksViewController: tasksVC, addNewTaskViewController: addNewTaskVC)
    }

    func makeTasksViewController() -> TasksViewController {
        let viewModel = TasksViewModel(dataStore: TasksDataStore(), navigationControllerViewModel: sharedNavigationControllerViewModel)
        return TasksViewController.create(with: viewModel)
    }

    func makeAddNewTaskViewController(taskID: String?) -> AddNewTaskViewController {
        let viewModel = AddNewTaskViewModel(taskID: taskID, dataStore: TasksDataStore())
        return AddNewTaskViewController.create(with: viewModel)
    }

}
