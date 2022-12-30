//
//  GroupChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule
import SendbirdChatSDK

class GroupChannelViewController: UIViewController {
    
    private enum Constant {
        static let loadMoreThreshold: CGFloat = 100
    }
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.register(BasicMessageCell.self)
        tableView.register(BasicFileCell.self)
        tableView.register(PollCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        return tableView
    }()
    
    private lazy var messageInputView: MessageInputView = {
        let messageInputView = MessageInputView()
        messageInputView.delegate = self
        return messageInputView
    }()
    
    private weak var messageInputBottomConstraint: NSLayoutConstraint?
    
    var targetMessageForScrolling: BaseMessage?
    
    let channel: GroupChannel
    
    private let timestampStorage: TimestampStorage
    public private(set) lazy var pollUseCase:PollUseCase = PollUseCase(channel: channel)
    
    public private(set) lazy var messageListUseCase: GroupChannelMessageListUseCase = {
        let messageListUseCase = GroupChannelMessageListUseCase(channel: channel, timestampStorage: timestampStorage)
        messageListUseCase.delegate = self
        return messageListUseCase
    }()
    
    public private(set) lazy var userMessageUseCase = GroupChannelUserMessageUseCase(channel: channel)
    
    public private(set) lazy var fileMessageUseCase = GroupChannelFileMessageUseCase(channel: channel)
    
    public private(set) lazy var settingUseCase = GroupChannelSettingUseCase(channel: channel)
    
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
    
    init(channel: GroupChannel, timestampStorage: TimestampStorage) {
        self.channel = channel
        self.timestampStorage = timestampStorage
        super.init(nibName: nil, bundle: nil)
        self.pollUseCase.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(messageInputView)
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        messageInputBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            messageInputView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            messageInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputView.heightAnchor.constraint(equalToConstant: 50),
            messageInputBottomConstraint
        ].compactMap { $0 })
        
        setupNavigation()
        
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
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let touchPoint = sender.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }
        
        let message = messageListUseCase.messages[indexPath.row]
        
        handleLongPress(for: message)
    }
    
}

// MARK: - UITableViewDataSource

extension GroupChannelViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageListUseCase.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageListUseCase.messages[indexPath.row]
        if let fileMessage = message as? FileMessage {
            let cell: BasicFileCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: fileMessage)
            return cell
        } else {
            let userMessage = message as? UserMessage
            if let poll = userMessage?.poll{
                let cell:PollCell = tableView.dequeueReusableCell(for: indexPath)
                cell.delegate = self
                cell.configure(poll)
                return cell
            }
            let cell: BasicMessageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: message)
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension GroupChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y - Constant.loadMoreThreshold <= 0 {
            messageListUseCase.loadPreviousMessages()
        }
        
        if scrollView.contentOffset.y + Constant.loadMoreThreshold >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            messageListUseCase.loadNextMessages()
        }
    }
    
}

// MARK: - GroupChannelMessageListUseCaseDelegate

extension GroupChannelViewController: GroupChannelMessageListUseCaseDelegate {
    
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didReceiveError error: SBError) {
        presentAlert(error: error)
    }
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateMessages messages: [BaseMessage]) {
        tableView.reloadData()
        scrollToFocusMessage()
    }
    
    private func scrollToFocusMessage() {
        guard let focusMessage = targetMessageForScrolling,
              focusMessage.messageId == messageListUseCase.messages.last?.messageId else { return }
        self.targetMessageForScrolling = nil
        
        let focusMessageIndexPath = IndexPath(row: messageListUseCase.messages.count - 1, section: 0)
        
        tableView.scrollToRow(at: focusMessageIndexPath, at: .bottom, animated: false)
    }
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateChannel channel: GroupChannel) {
        title = channel.name
    }
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didDeleteChannel channel: GroupChannel) {
        presentAlert(title: "This channel has been deleted", message: nil) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - MessageInputViewDelegate

extension GroupChannelViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String) {
        targetMessageForScrolling = userMessageUseCase.sendMessage(message) { [weak self] result in
            switch result {
            case .success(let sendedMessage):
                self?.targetMessageForScrolling = sendedMessage
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
        messageInputBottomConstraint?.constant = -keyboardHeight
        
        keyboardInfo.animate { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willHideKeyboardWith keyboardInfo: KeyboardInfo) {
        messageInputBottomConstraint?.constant = keyboardInfo.height
        
        keyboardInfo.animate { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
}