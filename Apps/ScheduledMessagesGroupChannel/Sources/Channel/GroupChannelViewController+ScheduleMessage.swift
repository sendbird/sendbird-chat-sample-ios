//
//  GroupChannelViewController+ScheduleMessage.swift
//  ScheduledMessagesGroupChannel
//
//  Created by Mihai Moisanu on 20.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit

extension GroupChannelViewController{
    
    func presentScheduleMessageAlert(onDateSelected: @escaping (Int64) -> Void){
        let alert = UIAlertController(title: "Schedule message", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Tommorow at 9:00AM", style: .default){ _ in
            guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {return}
            guard let timestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: date)?.timeIntervalSince1970 else { return }
            onDateSelected(Int64(timestamp * 1000))
        })
        alert.addAction(UIAlertAction(title: "Next Monday at 9:00 AM", style: .default){  _ in
            let nextMonday = Date().next(.monday)
            guard let timestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: nextMonday)?.timeIntervalSince1970 else { return }
            onDateSelected(Int64(timestamp * 1000))
        })
        alert.addAction(UIAlertAction(title: "Custom", style: .default, handler: {[weak self] _ in
            self?.presentDateTimePicker(onDateSelected: onDateSelected)
        }))
        present(alert, animated: true)
    }
    
    
    
    func presentDateTimePicker(onDateSelected: @escaping (Int64) -> Void){
        let datePicker = UIAlertController(title: "Select Time", onDateSelected: { date in
            onDateSelected(Int64(date.timeIntervalSince1970 * 1000))
        })
        present(datePicker, animated: true)
    }
}

extension Date{
    public func next(_ weekday: Weekday,
                     direction: Calendar.SearchDirection = .forward,
                     considerToday: Bool = false) -> Date
    {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(weekday: weekday.rawValue)
        
        if considerToday &&
            calendar.component(.weekday, from: self) == weekday.rawValue
        {
            return self
        }
        
        return calendar.nextDate(after: self,
                                 matching: components,
                                 matchingPolicy: .nextTime,
                                 direction: direction)!
    }
    
    public enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
}
