//
//  MessageInputView.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit

@IBDesignable
public class MessageInputView: UIView, NibLoadable {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
}
