//
//  ScheduledMessageInputView.swift
//
//  Created by Mihai Moisanu on 20.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule

public protocol ScheduledMessageInputViewDelegate: AnyObject {
    func messageInputView(_ messageInputView: ScheduledMessageInputView, didTouchSendFileMessageButton sender: UIButton)
    func messageInputView(_ messageInputView: ScheduledMessageInputView, didTouchUserMessageButton sender: UIButton, message: String)
    func messageInputView(_ messageInputView: ScheduledMessageInputView, didLongPressMessageButton sender: UIButton, message:String)
    func messageInputView(_ messageInputView:ScheduledMessageInputView, didLongPressFileMessageButton sender: UIButton)
    func messageInputView(_ messageInputView: ScheduledMessageInputView, didStartTyping sender: UITextField)
    func messageInputView(_ messageInputView: ScheduledMessageInputView, didEndTyping sender: UITextField)
}

extension ScheduledMessageInputViewDelegate {
    public func messageInputView(_ messageInputView: ScheduledMessageInputView, didStartTyping sender: UITextField) { }
    public func messageInputView(_ messageInputView: ScheduledMessageInputView, didEndTyping sender: UITextField) { }
}

// MARK: - MessageInputView

public class ScheduledMessageInputView: UIView {
    
    private lazy var sendFileMessageButton: UIButton = {
        let sendFileMessageButton: UIButton = UIButton()
        sendFileMessageButton.setImage(CommonModuleAsset.imgBtnSendFileMsgNormal.image, for: .normal)
        sendFileMessageButton.setImage(CommonModuleAsset.imgBtnSendFileMsgPressed.image, for: .highlighted)
        sendFileMessageButton.addTarget(self, action: #selector(didTouchSendFileMessageButton), for: .touchUpInside)
        sendFileMessageButton.addGestureRecognizer(UILongPressGestureRecognizer(target:self, action: #selector(didLongPressFileButton)))
        return sendFileMessageButton
    }()
    
    private lazy var textFieldContainerView: UIView = {
        let textFieldContainerView = UIView()
        textFieldContainerView.backgroundColor = .secondarySystemBackground
        textFieldContainerView.layer.cornerRadius = 20
        textFieldContainerView.clipsToBounds = true
        return textFieldContainerView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 14)
        textField.placeholder = "Type a message..."
        textField.delegate = self
        return textField
    }()
    
    private lazy var sendUserMessageButton: UIButton = {
        let sendUserMessageButton: UIButton = UIButton()
        sendUserMessageButton.setImage(CommonModuleAsset.imgBtnSendUserMsgPressed.image, for: .normal)
        sendUserMessageButton.addTarget(self, action: #selector(didTouchUserMessageButton), for: .touchUpInside)
        sendUserMessageButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMessageButton)))
        return sendUserMessageButton
    }()
    
    public weak var delegate: ScheduledMessageInputViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(sendFileMessageButton)
        sendFileMessageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendFileMessageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            sendFileMessageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendFileMessageButton.widthAnchor.constraint(equalToConstant: 34),
            sendFileMessageButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        addSubview(textFieldContainerView)
        textFieldContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textFieldContainerView.leadingAnchor.constraint(equalTo: sendFileMessageButton.trailingAnchor, constant: 8),
            textFieldContainerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: textFieldContainerView.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: textFieldContainerView.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: textFieldContainerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: textFieldContainerView.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        addSubview(sendUserMessageButton)
        sendUserMessageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendUserMessageButton.leadingAnchor.constraint(equalTo: textFieldContainerView.trailingAnchor, constant: 10),
            sendUserMessageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sendUserMessageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendUserMessageButton.widthAnchor.constraint(equalToConstant: 25),
            sendUserMessageButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTouchSendFileMessageButton(_ sender: UIButton) {
        delegate?.messageInputView(self, didTouchSendFileMessageButton: sender)
    }
    
    @objc private func didTouchUserMessageButton(_ sender: UIButton) {
        guard let message = textField.text else { return }
        guard !message.isEmpty else { return }
        textField.text = ""
        delegate?.messageInputView(self, didTouchUserMessageButton: sender, message: message)
    }
    
    @objc private func didLongPressMessageButton(_ sender: UIButton){
        guard let message = textField.text else { return }
        guard !message.isEmpty else { return }
        textField.text = ""
        delegate?.messageInputView(self, didLongPressMessageButton: sender, message: message)
    }
    
    @objc private func didLongPressFileButton(_ sender:UIButton){
        delegate?.messageInputView(self, didLongPressFileMessageButton: sender)
    }
    
}

extension ScheduledMessageInputView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.messageInputView(self, didStartTyping: textField)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.messageInputView(self, didEndTyping: textField)
    }
}
