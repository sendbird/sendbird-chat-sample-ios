//
//  UIImage+Extension.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit

extension UIImage {
    static func named(_ name: String) -> UIImage? {
        ImageProvider.image(named: name)
    }
}

public class ImageProvider {
    public static func image(named: String) -> UIImage? {
        UIImage(named: named, in: Bundle(for: self), compatibleWith: nil)
    }
}
