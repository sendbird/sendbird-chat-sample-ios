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
    
    private let didSelectUsers: DidSelectUserHandler
    
    private lazy var viewModel: UserSelectionViewModel = {
        let viewModel = UserSelectionViewModel()
        viewModel.delegate = self
        return viewModel
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
    
    init(didSelectUsers: @escaping DidSelectUserHandler) {
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
        
        viewModel.reloadUsers()
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
        let numberOfSelectedUsers = viewModel.selectedUsers.count
        
        okButtonItem.title = "OK(\(numberOfSelectedUsers))"
        okButtonItem.isEnabled = numberOfSelectedUsers > 0
    }

    @objc private func onTouchCancelButton(_ sender: AnyObject) {
        dismiss(animated: true)
    }

    @objc private func onTouchOkButton(_ sender: AnyObject) {
        didSelectUsers(self, Array(viewModel.selectedUsers))
    }
    
}

// MARK: - UITableViewDataSource

extension UserSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableUserTableViewCell") as! SelectableUserTableViewCell
        let user = viewModel.users[indexPath.row]
        
        cell.configure(with: user, isSelected: viewModel.isSelectedUser(user))
        
        return cell
    }
    
}

// MARK: - UIApplicationDelegate

extension UserSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard viewModel.users.count > 0 && indexPath.row == viewModel.users.count - 1 else { return }
        
        viewModel.loadNextPage()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]

        viewModel.toggleSelectUser(user)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - UserSelectionViewModelDelegate

extension UserSelectionViewController: UserSelectionViewModelDelegate {

    func userSelectionViewModel(_ userSelectionViewModel: UserSelectionViewModel, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func userSelectionViewModel(_ userSelectionViewModel: UserSelectionViewModel, didUpdateUsers users: [SBDUser]) {
        tableView.reloadData()
    }
    
    func userSelectionViewModel(_ userSelectionViewModel: UserSelectionViewModel, didUpdateSelectedUsers users: [SBDUser]) {
        updateOkButton()
    }

}
