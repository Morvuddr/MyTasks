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
import RxRealm

class TasksViewController: UIViewController {

    // MARK: - Properties
    private var viewModel: TasksViewModel!
    private let bag = DisposeBag()

    private var tasks: [Task]!

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
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.tasks.subscribe(onNext: { [weak self] tasks in
            guard let sself = self else { return }
            sself.tasks = tasks
        }).disposed(by: bag)
        viewModel.changeset.subscribe(onNext: { [weak self] changeset in
            guard let sself = self else { return }
            if let changes = changeset {
                sself.tableView.applyChangeset(changes)
            } else {
                sself.tableView.reloadData()
            }
        }).disposed(by: bag)
    }
    @IBAction func addNewTaskButtonPressed(_ sender: UIButton) {
        viewModel.openAddNewTaskView.onNext(nil)
    }

}

extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell") as! TaskTableViewCell
        cell.setup(task: task)
        return cell
    }

}

extension TasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.openAddNewTaskView.onNext(cell.taskID)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { [weak self] (_, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
            self?.viewModel.deleteTask(taskID: cell.taskID)
        }
        if #available(iOS 11.0, *) {
            return [delete]
        } else {
            let check = UITableViewRowAction(style: .normal, title: "✓") { [weak self] (_, indexPath) in
                let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
                self?.viewModel.checkTask(by: cell.taskID)
            }
            return [delete, check]
        }
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let check = UIContextualAction(style: .normal, title: "✓") { [weak self] _,_,completion in
            let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
            self?.viewModel.checkTask(by: cell.taskID)
            completion(true)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [check])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }

}

extension UITableView {
    func applyChangeset(_ changes: RealmChangeset) {
        beginUpdates()
        deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .fade)
        endUpdates()
    }
}
