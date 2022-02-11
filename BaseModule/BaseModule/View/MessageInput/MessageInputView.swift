//
//  MessageInputView.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit

public protocol MessageInputViewDelegate: AnyObject {
    func messageInputView(_ messageInputView: MessageInputView, didTouchSendFileMessageButton sender: UIButton)
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String)
}

@IBDesignable
public class MessageInputView: UIView, NibLoadable {
        
    @IBOutlet private weak var textField: UITextField!
    
    public weak var delegate: MessageInputViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    @IBAction private func didTouchSendFileMessageButton(_ sender: UIButton) {
        delegate?.messageInputView(self, didTouchSendFileMessageButton: sender)
    }
    
    @IBAction private func didTouchUserMessageButton(_ sender: UIButton) {
        guard let message = textField.text else { return }
        textField.text = ""
        delegate?.messageInputView(self, didTouchUserMessageButton: sender, message: message)
    }
    
}
