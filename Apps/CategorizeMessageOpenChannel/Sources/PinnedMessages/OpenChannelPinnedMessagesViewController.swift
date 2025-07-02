//
//  OpenChannelPinnedMessagesViewController.swift
//  CategorizeMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 17.08.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//
import UIKit
import CommonModule
import SendbirdChatSDK

class OpenChannelPinnedMessagesViewController: UIViewController {

    private enum Constant {
        static let loadMoreThreshold: CGFloat = 100
    }

    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.register(CategorizeUserMessageCell.self)
        tableView.register(BasicFileCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140.0
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    var targetMessageForScrolling: BaseMessage?
    private var isInitialLoad = true

    let channel: OpenChannel

    public private(set) lazy var messageListUseCase: OpenChannelMessageListUseCase = {
        let messageListUseCase = OpenChannelPinnedMessageListUseCase(channel: channel)
        messageListUseCase.delegate = self
        return messageListUseCase
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
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        setupNavigation()

        messageListUseCase.loadInitialMessages()
    }

    private func setupNavigation() {
        title = "Pinned Messages"
    }
}

// MARK: - UITableViewDataSource

extension OpenChannelPinnedMessagesViewController: UITableViewDataSource {

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
            let cell: CategorizeUserMessageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.updateMessageDetails(with: message)
            return cell
        }
    }

}

// MARK: - UITableViewDelegate

extension OpenChannelPinnedMessagesViewController: UITableViewDelegate {

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

extension OpenChannelPinnedMessagesViewController: OpenChannelMessageListUseCaseDelegate {

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

        let scrollPosition: UITableView.ScrollPosition = (messageIndex == messageListUseCase.messages.count - 1) ? .bottom : .top
        tableView.scrollToRow(at: focusMessageIndexPath, at: scrollPosition, animated: false)
    }

}

