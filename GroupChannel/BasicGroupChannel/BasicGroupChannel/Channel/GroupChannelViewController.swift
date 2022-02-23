//
//  GroupChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule
import SendBirdSDK

class GroupChannelViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageInputView: MessageInputView!
    @IBOutlet private weak var messageInputBottomConstraint: NSLayoutConstraint!
    
    private let channel: SBDGroupChannel
    
    private let timestampStorage: TimestampStorage
    
    public private(set) lazy var messageListUseCase: GroupChannelMessageListUseCase = {
        let messageListUseCase = GroupChannelMessageListUseCase(channel: channel, isReversed: true, timestampStorage: timestampStorage)
        messageListUseCase.delegate = self
        return messageListUseCase
    }()
    
    public private(set) lazy var userMessageUseCase = GroupChannelUserMessageUseCase(channel: channel)
    
    public private(set) lazy var fileMessageUseCase = GroupChannelFileMessageUseCase(channel: channel)
    
    public private(set) lazy var imagePickerRouter: ImagePickerRouter = {
        let imagePickerRouter = ImagePickerRouter(target: self, sourceTypes: [.photoLibrary, .photoCamera, .videoCamera])
        imagePickerRouter.delegate = self
        return imagePickerRouter
    }()
    
    private lazy var keyboardObserver: KeyboardObserver = {
        let keyboardObserver = KeyboardObserver()
        keyboardObserver.delegate = self
        return keyboardObserver
    }()
    
    init(channel: SBDGroupChannel, timestampStorage: TimestampStorage) {
        self.channel = channel
        self.timestampStorage = timestampStorage
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardObserver.add()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageListUseCase.markAsRead()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardObserver.remove()
    }
    
    private func setupNavigation() {
        title = channel.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Setting", style: .plain, target: self, action: #selector(didTouchSettingButton))
    }
    
    @objc private func didTouchSettingButton() {
        let settingController = GroupChannelSettingViewController(channel: channel)
        
        navigationController?.pushViewController(settingController, animated: true)
    }
    
    private func setupTableView() {
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(GroupChannelOutgoingMessageCell.self)
        tableView.registerNib(GroupChannelIncomingMessageCell.self)
        tableView.registerNib(GroupChannelOutgoingImageCell.self)
        tableView.registerNib(GroupChannelIncomingImageCell.self)
        
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
        let isOutgoingMessage = messageListUseCase.isOutgoingMessage(message)
        
        if let fileMessage = message as? SBDFileMessage {
            let cell: GroupChannelImageCell
            
            if isOutgoingMessage {
                cell = tableView.dequeueReusableCell(for: indexPath) as GroupChannelOutgoingImageCell
            } else {
                cell = tableView.dequeueReusableCell(for: indexPath) as GroupChannelIncomingImageCell
            }
            
            cell.configure(with: fileMessage)
            (cell as? GroupChannelOutgoingCell)?.delegate = self
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            return cell
        } else if let userMessage = message as? SBDUserMessage {
            let cell: GroupChannelMessageCell
            
            if isOutgoingMessage {
                cell = tableView.dequeueReusableCell(for: indexPath) as GroupChannelOutgoingMessageCell
            } else {
                cell = tableView.dequeueReusableCell(for: indexPath) as GroupChannelIncomingMessageCell
            }
            
            cell.configure(with: userMessage)
            (cell as? GroupChannelOutgoingCell)?.delegate = self
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            return cell
        } else {
            return UITableViewCell()
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

// MARK: - GroupChannelMessageListUseCaseDelegate

extension GroupChannelViewController: GroupChannelMessageListUseCaseDelegate {
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateMessages messages: [SBDBaseMessage]) {
        tableView.reloadData()
    }
    
}

// MARK: - GroupChannelOutgoingCellDelegate

extension GroupChannelViewController: GroupChannelOutgoingCellDelegate {
    func groupChannelOutgoingCell(_ cell: GroupChannelOutgoingCell, didTouchResendButton resendButton: UIButton, forUserMessage message: SBDUserMessage) {
        userMessageUseCase.resendMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    func groupChannelOutgoingCell(_ cell: GroupChannelOutgoingCell, didTouchResendButton resendButton: UIButton, forFileMessage message: SBDFileMessage) {
        fileMessageUseCase.resendMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
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

// MARK: - KeyboardObserverDelegate

extension GroupChannelViewController: KeyboardObserverDelegate {
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willShowKeyboardWith keyboardInfo: KeyboardInfo) {
        let keyboardHeight = keyboardInfo.height - view.safeAreaInsets.bottom
        messageInputBottomConstraint.constant = -keyboardHeight
        
        keyboardInfo.animate { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willHideKeyboardWith keyboardInfo: KeyboardInfo) {
        messageInputBottomConstraint.constant = keyboardInfo.height
        
        keyboardInfo.animate { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
}
