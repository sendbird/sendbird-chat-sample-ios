//
//  TimePicker.swift
//  PollsGroupChannel
//
//  Created by Mihai Moisanu on 22.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit

extension UIAlertController{

    convenience init(title:String, onDateSelected: @escaping (Date) -> Void){
        self.init(title: title, message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.locale = .current
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        view.addSubview(datePicker)
        addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
            onDateSelected(datePicker.date)
        }))
        let height: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
        view.addConstraint(height)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }

}
