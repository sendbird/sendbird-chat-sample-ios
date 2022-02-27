//
//  OpenChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule
import SendBirdSDK

class OpenChannelViewController: UIViewController {
    
    private enum Constant {
        static let loadMoreThreshold: CGFloat = 100
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageInputView: MessageInputView!
    @IBOutlet private weak var messageInputBottomConstraint: NSLayoutConstraint!
    
    private let channel: SBDOpenChannel
    
    public private(set) lazy var messageListUseCase: OpenChannelMessageListUseCase = {
        let messageListUseCase = OpenChannelMessageListUseCase(channel: channel, isReversed: true)
        messageListUseCase.delegate = self
        return messageListUseCase
    }()
    
    public private(set) lazy var userMessageUseCase = OpenChannelUserMessageUseCase(channel: channel)
    
    public private(set) lazy var fileMessageUseCase = OpenChannelFileMessageUseCase(channel: channel)
    
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
    
    init(channel: SBDOpenChannel) {
        self.channel = channel
        super.init(nibName: "OpenChannelViewController", bundle: Bundle(for: Self.self))
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
    
    @objc private func didTouchSettingButton() {
        let settingController = OpenChannelSettingViewController(channel: channel)
        
        navigationController?.pushViewController(settingController, animated: true)
    }
    
    private func setupTableView() {
        tableView.flipVertically()
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
        
        if let fileMessage = message as? SBDFileMessage {
            let cell: BasicFileCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: fileMessage)
            cell.flipVertically()
            return cell
        } else {
            let cell: BasicMessageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: message)
            cell.flipVertically()
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
            messageListUseCase.loadNextMessages()
        }
         
        if scrollView.contentOffset.y + Constant.loadMoreThreshold >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            messageListUseCase.loadPreviousMessages()
        }
    }
    
}

// MARK: - GroupChannelUseCaseDelegate

extension OpenChannelViewController: OpenChannelMessageListUseCaseDelegate {
    
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateMessages messages: [SBDBaseMessage]) {
        tableView.reloadData()
    }
    
}

// MARK: - MessageInputViewDelegate

extension OpenChannelViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String) {
        userMessageUseCase.sendMessage(message) { [weak self] result in
            switch result {
            case .success(let message):
                self?.messageListUseCase.didSendMessage(message)
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

extension OpenChannelViewController: KeyboardObserverDelegate {
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willShowKeyboardWith keyboardInfo: KeyboardInfo) {
        let keyboardHeight = keyboardInfo.height - self.view.safeAreaInsets.bottom
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
