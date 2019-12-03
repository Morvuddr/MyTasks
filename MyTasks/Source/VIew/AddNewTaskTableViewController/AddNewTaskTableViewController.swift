//
//  AddNewTaskTableViewController.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UserNotifications

class AddNewTaskViewController: UITableViewController {

    // MARK: - Properties

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var priorityButtons: [UIButton]! {
        didSet {
            priorityButtons.forEach({ $0.layer.cornerRadius = $0.bounds.width / 2 })
        }
    }
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.setupViews(cornerRadius: 8)
        }
    }
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    private var datePickerVisible = false

    private var viewModel: AddNewTaskViewModel!
    private let bag = DisposeBag()

    // MARK: - Methods

    static func create(with viewModel: AddNewTaskViewModel) -> AddNewTaskViewController {
        let controller = AddNewTaskViewController.getInstance() as! AddNewTaskViewController
        controller.viewModel = viewModel
        return controller
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews(with: viewModel)
        bindTextFields(to: viewModel)
        bindControls(to: viewModel)


        viewModel.isEditing.subscribe(onNext: { [weak self] status in
            let title = status ? "ИЗМЕНИТЬ" : "СОЗДАТЬ"
            self?.actionButton.setTitle(title, for: .normal)
            }, onCompleted: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    private func setupViews(with viewModel: AddNewTaskViewModel) {
        nameTextField.text = viewModel.nameSubject.value
        nameTextField.delegate = self
        descriptionTextView.text = viewModel.descriptionSubject.value
        descriptionTextView.delegate = self
        descriptionTextView.placeholder = "Введите текст"
        priorityButtons.forEach({ $0.setTitle("", for: .normal) })
        priorityButtons.first(where: { $0.tag == viewModel.prioritySubject.value.rawValue })?.setTitle("✓", for: .normal)
        viewModel.dateSubject
            .map({ (date) -> String in
                return createStringFromDate(date)
            }).subscribe(onNext: { [weak self] dateStr in
                self?.dueDateLabel.text = dateStr
            }).disposed(by: bag)
        shouldRemindSwitch.isOn = viewModel.shoudRemind.value
        datePicker.date = viewModel.dateSubject.value

    }

    private func bindTextFields(to viewModel: AddNewTaskViewModel) {
        nameTextField.rx.text.orEmpty.bind(to: viewModel.nameSubject).disposed(by: bag)
        descriptionTextView.rx.text.orEmpty.bind(to: viewModel.descriptionSubject).disposed(by: bag)
    }

    private func bindControls(to viewModel: AddNewTaskViewModel) {
        viewModel.actionButtonIsEnabled.subscribe(onNext: { [weak self] status in
            self?.actionButton.isEnabled = status
        }).disposed(by: bag)
        actionButton.rx.tap.subscribe(onNext: { _ in
            viewModel.save()
        }).disposed(by: bag)
        shouldRemindSwitch.rx.isOn.bind(to: viewModel.shoudRemind).disposed(by: bag)
        datePicker.rx.date.bind(to: viewModel.dateSubject).disposed(by: bag)
    }

    @IBAction func prioritySelected(_ sender: UIButton) {
        priorityButtons.forEach({ $0.setTitle("", for: .normal) })
        sender.setTitle("✓", for: .normal)
        viewModel.prioritySubject.accept(TaskPriority(rawValue: sender.tag) ?? .low)
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func shouldRemindAction(_ sender: UISwitch) {
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        if shouldRemindSwitch.isOn {
            DispatchQueue.main.async {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound]) {
                    granted, error in
                }
            }
        }
    }

    private func showDatePicker(){
        datePickerVisible = true
        tableView.insertRows(at: [IndexPath(row: 5, section: 0)], with: .fade)
        datePicker.date = viewModel.dateSubject.value
    }

    private func hideDateCell(){
        if datePickerVisible {
            datePickerVisible = false
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 5, section: 0)], with: .fade)
            tableView.endUpdates()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && datePickerVisible {
            return 6
        } else {
            return super.tableView(tableView,
                                   numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                return descriptionTextView.text.heightWithConstrainedWidth(width: tableView.frame.width - 32, font: UIFont.systemFont(ofSize: 14)) + 30
            } else if indexPath.row == 5 {
                return 217
            }
        }

        return super.tableView(tableView, heightForRowAt: indexPath)

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 5 && indexPath.section == 0 {
            return datePickerCell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 4 && indexPath.section == 0 {
            datePickerVisible ? hideDateCell() : showDatePicker()
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 4 && indexPath.section == 0 {
            return indexPath
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if (indexPath.row == 5 && indexPath.section == 0) {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }

}

extension AddNewTaskViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hideDateCell()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let maxLength = 20
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)

        return newText.count <= maxLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

}

extension AddNewTaskViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        hideDateCell()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        textView.changePlaceholderVisibility()
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 200
        let oldText = textView.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: text)

        return newText.count <= maxLength
    }

}
