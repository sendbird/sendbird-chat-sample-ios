//
//  NibLoadable.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/09.
//
//  https://stackoverflow.com/a/47295926

import UIKit

public protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable where Self: UIView {

    public static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }

    public static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }

    public func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}
