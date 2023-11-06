//
//  UserSelectionViewController.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import SendbirdChatSDK

public class UserSelectionViewController: UIViewController {
    
    public typealias DidSelectUserHandler = (UserSelectionViewController, [User]) -> Void
    
    private let channel: GroupChannel?
    
    private let didSelectUsers: DidSelectUserHandler
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectableUserTableViewCell.self)
        return tableView
    }()
    
    private lazy var useCase: GroupChannelUserSelectionUseCase = {
        let useCase = GroupChannelUserSelectionUseCase(channel: channel)
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
    
    public init(channel: GroupChannel? = nil, didSelectUsers: @escaping DidSelectUserHandler) {
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
        
        useCase.reloadUsers()
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
    }
    
}

// MARK: - UITableViewDataSource

extension UserSelectionViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.users.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectableUserTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let user = useCase.users[indexPath.row]
        
        cell.configure(with: user, isSelected: useCase.isSelectedUser(user))
        
        return cell
    }
    
}

// MARK: - UIApplicationDelegate

extension UserSelectionViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard useCase.users.count > 0 && indexPath.row == useCase.users.count - 1 else { return }
        
        useCase.loadNextPage()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = useCase.users[indexPath.row]

        useCase.toggleSelectUser(user)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - UserSelectionUseCaseDelegate

extension UserSelectionViewController: GroupChannelUserSelectionUseCaseDelegate {

    public func userSelectionUseCase(_ userSelectionUseCase: GroupChannelUserSelectionUseCase, didReceiveError error: SBError) {
        presentAlert(error: error)
    }
    
    public func userSelectionUseCase(_ userSelectionUseCase: GroupChannelUserSelectionUseCase, didUpdateUsers users: [User]) {
        tableView.reloadData()
    }
    
    public func userSelectionUseCase(_ userSelectionUseCase: GroupChannelUserSelectionUseCase, didUpdateSelectedUsers users: [User]) {
        updateOkButton()
    }

}
