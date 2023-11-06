//
//  UserDefault.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import Foundation

@propertyWrapper
public struct UserDefault<Value> {
    
    private let key: String
    private let defaultValue: Value
    private let container: UserDefaults
    
    public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
    
    public var wrappedValue: Value {
        get {
            return (container.object(forKey: key) as? Value) ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}
