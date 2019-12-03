//
//  Helpers.swift
//  MyTasks
//
//  Created by Игорь Бопп on 03.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import Foundation
import UserNotifications

// MARK: - Returns the date in string format

func createStringFromDate(_ date: Date) -> String {
    // initialize the date formatter and set the style
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: "ru_RU")

    // get the date time String from the date object
    return formatter.string(from: date)
}

func getRemindDate(from now: Date) -> Date {
    var dateComponent = DateComponents()
    dateComponent.day = 1
    let calendar = Calendar(identifier: .gregorian)
    let hour = calendar.component(.hour, from: now)
    let minute = calendar.component(.minute, from: now)
    let floorDate = calendar.date(bySettingHour: hour,
                                  minute: minute - (minute % 5),
                                  second: 0,
                                  of: now)!
    return (calendar.date(byAdding: dateComponent, to: floorDate))!
}

func scheduleNotification(for task: Task) {
    removeNotification(for: task.taskID)
    let calendar = Calendar(identifier: .gregorian)
    var hourComponent = DateComponents()
    hourComponent.hour = -1
    let remindDate = calendar.date(byAdding: hourComponent, to: task.date)

    if let remindDate = remindDate, task.shouldRemind && remindDate > Date() && !task.checked {
        let content = UNMutableNotificationContent()
        content.title = "Скоро закончится срок у задачи:"
        content.body = task.name
        content.sound = UNNotificationSound.default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: remindDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,repeats: false)
        let request = UNNotificationRequest(identifier: task.taskID, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}

func removeNotification(for notificationID: String) {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [notificationID])
}
