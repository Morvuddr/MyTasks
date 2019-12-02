//
//  NavigationController.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import UIKit
import RxSwift

class NavigationController: UINavigationController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var viewModel: NavigationControllerViewModel!

    private var tasksViewController: TasksViewController!
    private var addNewTaskViewController: ((String?) -> AddNewTaskViewController)!

    // MARK: - Methods

    static func create(with viewModel: NavigationControllerViewModel, tasksViewController: TasksViewController, addNewTaskViewController: @escaping (String?) -> AddNewTaskViewController) -> NavigationController {
        let controller = NavigationController.getInstance() as! NavigationController
        controller.viewModel = viewModel
        controller.tasksViewController = tasksViewController
        controller.addNewTaskViewController = addNewTaskViewController
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe(to: viewModel.view)
    }

    private func subscribe(to observable: Observable<CurrentView>) {
        observable
            .subscribe(onNext: { [weak self] currentView in
                guard let self = self else { return }
                self.present(view: currentView)
            })
            .disposed(by: disposeBag)
    }


    private func present(view: CurrentView) {
        switch view {
        case .tasks:
            pushViewController(tasksViewController, animated: false)
        case .addNewTask(let taskID):
            pushViewController(addNewTaskViewController(taskID), animated: true)
        }
    }


}
