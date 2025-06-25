//
//  OpenChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule
import SendbirdChatSDK

class OpenChannelViewController: UIViewController {
    
    private enum Constant {
        static let loadMoreThreshold: CGFloat = 100
    }
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.register(BasicMessageCell.self)
        tableView.register(BasicFileCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140.0
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
    private var isInitialLoad = true
    
    let channel: OpenChannel
    
    public private(set) lazy var messageListUseCase: OpenChannelMessageListUseCase = {
        let messageListUseCase = OpenChannelMessageListUseCase(channel: channel)
        messageListUseCase.delegate = self
        return messageListUseCase
    }()
    
    public private(set) lazy var userMessageUseCase = OpenChannelUserMessageUseCase(channel: channel)
    
    public private(set) lazy var fileMessageUseCase = OpenChannelFileMessageUseCase(channel: channel)
    
    private(set) lazy var updateMessageUseCase = UpdateMessageUseCase(channel: channel)
    
    public private(set) lazy var settingUseCase = OpenChannelSettingUseCase(channel: channel)
    
    public private(set) lazy var imagePickerRouter: ImagePickerRouter = {
        let imagePickerRouter = ImagePickerRouter(target: self, sourceTypes: [.photoCamera, .photoLibrary])
        imagePickerRouter.delegate = self
        return imagePickerRouter
    }()
    
    private lazy var keyboardObserver: KeyboardObserver = {
        let keyboardObserver = KeyboardObserver()
        keyboardObserver.delegate = self
        return keyboardObserver
    }()
    
    init(channel: OpenChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
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
        messageListUseCase.addEventObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardObserver.remove()
        messageListUseCase.removeEventObserver()
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
        
        presentEditMessageAlert(for: message)
    }

}

// MARK: - UITableViewDataSource

extension OpenChannelViewController: UITableViewDataSource {
    
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
            let cell: BasicMessageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: message)
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension OpenChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y - Constant.loadMoreThreshold <= 0 {
            if let visibleIndexPaths = tableView.indexPathsForVisibleRows,
               let firstVisibleIndexPath = visibleIndexPaths.first,
               firstVisibleIndexPath.row < messageListUseCase.messages.count {
                targetMessageForScrolling = messageListUseCase.messages[firstVisibleIndexPath.row]
            }
            messageListUseCase.loadPreviousMessages()
        }
         
        if scrollView.contentOffset.y + Constant.loadMoreThreshold >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            messageListUseCase.loadNextMessages()
        }
    }
    
}

// MARK: - GroupChannelUseCaseDelegate

extension OpenChannelViewController: OpenChannelMessageListUseCaseDelegate {
    
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateChannel channel: OpenChannel) {
        title = channel.name
    }
    
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didDeleteChannel channel: OpenChannel) {
        presentAlert(title: "This channel has been deleted", message: nil) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didReceiveError error: SBError) {
        presentAlert(error: error)
    }
    
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateMessages messages: [BaseMessage]) {
        tableView.reloadData()
        if isInitialLoad && !messages.isEmpty {
            targetMessageForScrolling = messages.last
            isInitialLoad = false
        }
        scrollToFocusMessage()
    }
    
    private func scrollToFocusMessage() {
        defer { self.targetMessageForScrolling = nil }
        
        guard let focusMessage = targetMessageForScrolling else { return }
        
        guard let messageIndex = messageListUseCase.messages.firstIndex(where: { 
            $0.messageId == focusMessage.messageId || $0.requestId == focusMessage.requestId 
        }) else { return }
        
        let focusMessageIndexPath = IndexPath(row: messageIndex, section: 0)
        
        tableView.scrollToRow(at: focusMessageIndexPath, at: .bottom, animated: false)
        let scrollPosition: UITableView.ScrollPosition = (messageIndex == messageListUseCase.messages.count - 1) ? .bottom : .top
        tableView.scrollToRow(at: focusMessageIndexPath, at: scrollPosition, animated: false)
    }

}

// MARK: - MessageInputViewDelegate

extension OpenChannelViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String) {
        var sendingMessage: BaseMessage?
        
        sendingMessage = userMessageUseCase.sendMessage(message) { [weak self] result in
            switch result {
            case .success(let message):
                self?.targetMessageForScrolling = message
                self?.messageListUseCase.didSuccessSendMessage(message)
            case .failure(let error):
                self?.targetMessageForScrolling = nil
                self?.messageListUseCase.didFailSendMessage(sendingMessage)
                self?.presentAlert(error: error)
            }
        }
        
        guard let sendingMessage = sendingMessage else { return }
        
        targetMessageForScrolling = sendingMessage
        messageListUseCase.didStartSendMessage(sendingMessage)
    }
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchSendFileMessageButton sender: UIButton) {
        presentAttachFileAlert()
    }
    
}

// MARK: - KeyboardObserverDelegate

extension OpenChannelViewController: KeyboardObserverDelegate {
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willShowKeyboardWith keyboardInfo: KeyboardInfo) {
        let keyboardHeight = keyboardInfo.height - self.view.safeAreaInsets.bottom
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
