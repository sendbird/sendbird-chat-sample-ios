//
//  UserSelectionViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import SendBirdSDK
import BaseModule

class UserSelectionViewController: UIViewController {
    
    typealias DidSelectUserHandler = (UserSelectionViewController, [SBDUser]) -> Void
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let excludeUsers: [SBDUser]
    
    private let didSelectUsers: DidSelectUserHandler
    
    private lazy var useCase: UserSelectionUseCase = {
        let useCase = UserSelectionUseCase(excludeUsers: excludeUsers)
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
    
    init(excludeUsers: [SBDUser] = [], didSelectUsers: @escaping DidSelectUserHandler) {
        self.excludeUsers = excludeUsers
        self.didSelectUsers = didSelectUsers
        super.init(nibName: "UserSelectionViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectableUserTableViewCell.nib(), forCellReuseIdentifier: "SelectableUserTableViewCell")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableUserTableViewCell") as! SelectableUserTableViewCell
        let user = useCase.users[indexPath.row]
        
        cell.configure(with: user, isSelected: useCase.isSelectedUser(user))
        
        return cell
    }
    
}

// MARK: - UIApplicationDelegate

extension UserSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard useCase.users.count > 0 && indexPath.row == useCase.users.count - 1 else { return }
        
        useCase.loadNextPage()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = useCase.users[indexPath.row]

        useCase.toggleSelectUser(user)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - UserSelectionUseCaseDelegate

extension UserSelectionViewController: UserSelectionUseCaseDelegate {

    func userSelectionUseCase(_ userSelectionUseCase: UserSelectionUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func userSelectionUseCase(_ userSelectionUseCase: UserSelectionUseCase, didUpdateUsers users: [SBDUser]) {
        tableView.reloadData()
    }
    
    func userSelectionUseCase(_ userSelectionUseCase: UserSelectionUseCase, didUpdateSelectedUsers users: [SBDUser]) {
        updateOkButton()
    }

}
