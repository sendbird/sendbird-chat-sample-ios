//
//  UIView+Extension.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/27.
//

import UIKit

extension UIView {
    
    public func flipVertically() {
        transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
}
