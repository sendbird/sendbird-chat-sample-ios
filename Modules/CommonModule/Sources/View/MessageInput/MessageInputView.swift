//
//  MessageInputView.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit

public protocol MessageInputViewDelegate: AnyObject {
    func messageInputView(_ messageInputView: MessageInputView, didTouchSendFileMessageButton sender: UIButton)
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String)
    func messageInputView(_ messageInputView: MessageInputView, didStartTyping sender: UITextField)
    func messageInputView(_ messageInputView: MessageInputView, didEndTyping sender: UITextField)
}

@IBDesignable
public class MessageInputView: UIView, NibLoadable {
        
    @IBOutlet private weak var textField: UITextField!
    
    public weak var delegate: MessageInputViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        setupTextField()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        setupTextField()
    }
    
    func setupTextField(){
        textField.delegate = self
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

extension MessageInputView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.messageInputView(self, didStartTyping: textField)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.messageInputView(self, didEndTyping: textField)
    }
}
