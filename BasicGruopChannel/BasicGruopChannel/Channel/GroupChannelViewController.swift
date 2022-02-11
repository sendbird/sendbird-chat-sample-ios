//
//  GroupChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import BaseModule
import SendBirdSDK

class GroupChannelViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageInputView: MessageInputView!
    
    private let channel: SBDGroupChannel
    
    private lazy var messagesUseCase: GroupChannelUseCase = {
        let messagesUseCase = GroupChannelUseCase(channel: channel, isReversed: true)
        messagesUseCase.delegate = self
        return messagesUseCase
    }()
    
    private lazy var sendUseCase: SendGroupChannelUseCase = {
        let sendUseCase = SendGroupChannelUseCase(channel: channel)
        sendUseCase.delegate = self
        return sendUseCase
    }()
    
    init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init(nibName: "GroupChannelViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = channel.name
        
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupChannelCell")
        messageInputView.delegate = self
        
        messagesUseCase.loadInitialMessages()
    }

}

// MARK: - UITableViewDataSource

extension GroupChannelViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messagesUseCase.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelCell", for: indexPath)
        cell.textLabel?.text = messagesUseCase.messages[indexPath.row].message
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension GroupChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if willScrollReachTop(with: indexPath) {
            messagesUseCase.loadPreviousMessages()
        } else if willScrollReachBottom(with: indexPath) {
            messagesUseCase.loadNextMessages()
        }
    }
    
    private func willScrollReachTop(with indexPath: IndexPath) -> Bool {
        indexPath.row == messagesUseCase.messages.count - 1
    }
    
    private func willScrollReachBottom(with indexPath: IndexPath) -> Bool {
        indexPath.row == 0
    }

}

// MARK: - GroupChannelUseCaseDelegate

extension GroupChannelViewController: GroupChannelUseCaseDelegate {
    
    func groupChannelUseCase(_ groupChannelUseCase: GroupChannelUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func groupChannelUseCase(_ groupChannelUseCase: GroupChannelUseCase, didUpdateMessages messages: [SBDBaseMessage]) {
        tableView.reloadData()
    }
    
}

// MARK: - MessageInputViewDelegate

extension GroupChannelViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String) {
        sendUseCase.sendMessage(message)
    }
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchSendFileMessageButton sender: UIButton) {
        
    }
    
}

// MARK: - SendGroupChannelUseCaseDelegate

extension GroupChannelViewController: SendGroupChannelUseCaseDelegate {
    
    func sendGroupChannelUseCase(_ sendGroupChannelUseCase: SendGroupChannelUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
}
