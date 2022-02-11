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
    
    public private(set) lazy var messageListUseCase: GroupChannelMessageListUseCase = {
        let messageListUseCase = GroupChannelMessageListUseCase(channel: channel, isReversed: true)
        messageListUseCase.delegate = self
        return messageListUseCase
    }()
    
    public private(set) lazy var userMessageUseCase = GroupChannelUserMessageUseCase(channel: channel)
    
    public private(set) lazy var fileMessageUseCase = GroupChannelFileMessageUseCase(channel: channel)

    init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init(nibName: "GroupChannelViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        messageInputView.delegate = self
        
        messageListUseCase.loadInitialMessages()
    }
    
    private func setupNavigation() {
        title = channel.name
    }
    
    private func setupTableView() {
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupChannelCell.self, forCellReuseIdentifier: "GroupChannelCell")
        tableView.register(UINib(nibName: "GroupChannelFileCell", bundle: Bundle(for: GroupChannelFileCell.self)), forCellReuseIdentifier: "GroupChannelFileCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140.0
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let touchPoint = sender.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }

        let message = messageListUseCase.messages[indexPath.row]
        
        presentEditMessageAlert(for: message)
    }

}

// MARK: - UITableViewDataSource

extension GroupChannelViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageListUseCase.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageListUseCase.messages[indexPath.row]
        
        if let fileMessage = message as? SBDFileMessage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelFileCell", for: indexPath) as! GroupChannelFileCell
            
            cell.configure(with: fileMessage)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelCell", for: indexPath) as! GroupChannelCell
            
            cell.configure(with: message)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension GroupChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if willScrollReachTop(with: indexPath) {
            messageListUseCase.loadPreviousMessages()
        } else if willScrollReachBottom(with: indexPath) {
            messageListUseCase.loadNextMessages()
        }
    }
    
    private func willScrollReachTop(with indexPath: IndexPath) -> Bool {
        indexPath.row == messageListUseCase.messages.count - 1
    }
    
    private func willScrollReachBottom(with indexPath: IndexPath) -> Bool {
        indexPath.row == 0
    }

}

// MARK: - GroupChannelUseCaseDelegate

extension GroupChannelViewController: GroupChannelMessageListUseCaseDelegate {
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateMessages messages: [SBDBaseMessage]) {
        tableView.reloadData()
    }
    
}

// MARK: - MessageInputViewDelegate

extension GroupChannelViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String) {
        userMessageUseCase.sendMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchSendFileMessageButton sender: UIButton) {
        presentAttachFileAlert()
    }
    
}
