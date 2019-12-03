//
//  Helpers.swift
//  MyTasks
//
//  Created by Игорь Бопп on 03.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import Foundation

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
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: now)
    let minute = calendar.component(.minute, from: now)
    let floorDate = calendar.date(bySettingHour: hour,
                                          minute: minute - (minute % 30),
                                          second: 0,
                                          of: now)!
    return (calendar.date(byAdding: dateComponent, to: floorDate))!
}
