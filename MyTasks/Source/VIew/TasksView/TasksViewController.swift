//
//  ViewController.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TasksViewController: UIViewController {

    // MARK: - Properties
    private var viewModel: TasksViewModel!
    private let bag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewTaskButton: UIButton! {
        didSet {
            addNewTaskButton.setupViews(cornerRadius: addNewTaskButton.bounds.width / 2)
        }
    }

    // MARK: - Methods

    static func create(with viewModel: TasksViewModel) -> TasksViewController {
        let controller = TasksViewController.getInstance() as! TasksViewController
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [unowned self] in
            self.subscribe(to: self.viewModel.tasks)
        }
    }

    private func subscribe(to observable: Observable<[Task]>){

        observable.bind(to: tableView.rx.items(cellIdentifier: "TaskTableViewCell", cellType: TaskTableViewCell.self)) {
            (index, task: Task, cell) in
            cell.setup(task: task)
        }
        .disposed(by: bag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let cell = self?.tableView.cellForRow(at: indexPath) as? TaskTableViewCell else {
                    return
                }
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.viewModel.openAddNewTaskView.onNext(cell.taskID)
            })
            .disposed(by: bag)

        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let cell = self?.tableView.cellForRow(at: indexPath) as? TaskTableViewCell else {
                    return
                }
                self?.viewModel.deleteTask(taskID: cell.taskID)
            })
            .disposed(by: bag)
    }
    @IBAction func addNewTaskButtonPressed(_ sender: UIButton) {
        viewModel.openAddNewTaskView.onNext(nil)
    }



}

