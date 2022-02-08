//
//  DoNotDisturbInfo.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import Foundation

public struct DoNotDisturbInfo: Codable {
    var startHour: Int
    var startMin: Int
    var endHour: Int
    var endMin: Int
    var isDoNotDisturbOn: Bool
}
