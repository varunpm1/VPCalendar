//
//  DateHelper.swift
//  VPCalendarExample
//
//  Created by Varun P M on 04/06/18.
//  Copyright © 2018 Varun P M. All rights reserved.
//

import UIKit

// To avoid reinitializing again and again
private let calendar = Calendar.current
private var dateComponents = DateComponents()
private let dateFormatter = DateFormatter()
private let dateHelper = DateHelper()

class DateHelper {
    class func shared() -> DateHelper {
        return dateHelper
    }
    
    var currentYear: Int {
        return calendar.component(.year, from: Date())
    }
    
    var currentMonth: Int {
        return calendar.component(.month, from: Date())
    }
    
    var currentDay: Int {
        return calendar.component(.day, from: Date())
    }
    
    func weekDay(inMonth month: Int, andYear year: Int) -> Int {
        dateComponents.day = 1
        dateComponents.month = month
        dateComponents.year = year
        
        return calendar.component(.weekday, from: DateHelper.getDate())
    }
    
    func days(inMonth month: Int, andYear year: Int) -> Int {
        dateComponents.day = 1
        dateComponents.month = month
        dateComponents.year = year
        
        return calendar.range(of: .day, in: .month, for: DateHelper.shared().dateAtStartOfMonth())?.count ?? 0
    }
    
    func dateAtStartOfMonth() -> Date {
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        return DateHelper.getDate()
    }
    
    func isCurrentYear(forYear year: Int) -> Bool {
        return (currentYear == year)
    }
    
    func isCurrentMonth(forYear year: Int, forMonth month: Int) -> Bool {
        return (currentYear == year && currentMonth == month)
    }
    
    func isCurrentDate(forYear year: Int, forMonth month: Int, forDay day: Int) -> Bool {
        return (currentYear == year && currentMonth == month && currentDay == day)
    }
    
    static func getDate() -> Date {
        guard let date = calendar.date(from: dateComponents) else {
            assertionFailure("Couldn't calculate date based on components - \(dateComponents)")
            return Date()
        }
        
        return date
    }
}
