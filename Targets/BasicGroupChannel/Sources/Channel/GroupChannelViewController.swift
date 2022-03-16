//
//  GroupChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule
import SendbirdChat

class GroupChannelViewController: UIViewController {
    
    private enum Constant {
        static let loadMoreThreshold: CGFloat = 100
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageInputView: MessageInputView!
    @IBOutlet private weak var messageInputBottomConstraint: NSLayoutConstraint!

    var targetMessageForScrolling: SBDBaseMessage?
    
    let channel: SBDGroupChannel
    
    private let timestampStorage: TimestampStorage
    
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
        
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BasicMessageCell.self)
        tableView.register(BasicFileCell.self)
        
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
        
        if let fileMessage = message as? SBDFileMessage {
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
    

    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateMessages messages: [SBDBaseMessage]) {
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
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateChannel channel: SBDGroupChannel) {
        title = channel.name
    }
    
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didDeleteChannel channel: SBDGroupChannel) {
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
