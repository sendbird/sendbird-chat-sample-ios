//
//  MentionUserSelectionViewController.swift
//  MentionUsersInMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 05.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import CommonModule

public class MentionUserSelectionViewController: UIViewController {
    
    public typealias DidSelectUserHandler = (MentionUserSelectionViewController, [User]) -> Void
    
    private let channel: OpenChannel
    
    private let didSelectUsers: DidSelectUserHandler
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectableUserTableViewCell.self)
        return tableView
    }()
    
    private lazy var useCase: OpenChannelUserSelectionUseCase = {
        let useCase = OpenChannelUserSelectionUseCase(channel: channel)
        useCase.delegate = self
        return useCase
    }()
    
    private lazy var okButtonItem = UIBarButtonItem(
        title: "OK(0)",
        style: .plain,
        target: self,
        action: #selector(onTouchOkButton(_:))
    )
    
    private lazy var cancelButtonItem = UIBarButtonItem(
        title: "Cancel",
        style: .plain,
        target: self,
        action: #selector(onTouchCancelButton(_:))
    )
    
    public init(channel: OpenChannel, didSelectUsers: @escaping DidSelectUserHandler) {
        self.channel = channel
        self.didSelectUsers = didSelectUsers
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavigation()
        setupTableView()
        
        useCase.loadNextPage()
    }
    
    private func setupNavigation() {
        title = "Choose Member"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = okButtonItem
        navigationItem.leftBarButtonItem = cancelButtonItem
        updateOkButton()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateOkButton() {
        let numberOfSelectedUsers = useCase.selectedUsers.count
        
        okButtonItem.title = "OK(\(numberOfSelectedUsers))"
        okButtonItem.isEnabled = numberOfSelectedUsers > 0
    }

    @objc private func onTouchCancelButton(_ sender: AnyObject) {
        dismiss(animated: true)
    }

    @objc private func onTouchOkButton(_ sender: AnyObject) {
        didSelectUsers(self, Array(useCase.selectedUsers))
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource

extension MentionUserSelectionViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.participants.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectableUserTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let user = useCase.participants[indexPath.row]
        
        cell.configure(with: user, isSelected: useCase.isSelectedUser(user))
        
        return cell
    }
    
}

// MARK: - UIApplicationDelegate

extension MentionUserSelectionViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard useCase.participants.count > 0 && indexPath.row == useCase.participants.count - 1 else { return }
        
        useCase.loadNextPage()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = useCase.participants[indexPath.row]
        useCase.toggleSelectUser(user)
        updateOkButton()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - UserSelectionUseCaseDelegate

extension MentionUserSelectionViewController: OpenChannelParticipantListUseCaseDelegate {
    public func openChannelParticipantListUseCase(_ useCase: OpenChannelParticipantListUseCase, didReceiveError error: SBError) {
        presentAlert(error: error)
    }
    
    public func openChannelParticipantListUseCase(_ useCase: OpenChannelParticipantListUseCase, didUpdateParticipants participants: [User]) {
        tableView.reloadData()
    }
}
