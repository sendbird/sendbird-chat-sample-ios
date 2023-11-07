//
//  GroupChannelBannedUserListViewController.swift
//  BasicGroupChannel
//
//  Created by Ernest Hong on 2022/03/04.
//

import UIKit
import SendbirdChatSDK

class GroupMemberListViewController: UIViewController {

    private let channel: GroupChannel
    private var isBannedListQuery: Bool

    private lazy var useCase: GroupChannelMemberListUseCase = {
        let useCase = GroupChannelMemberListUseCase(channel: channel, isBannedListQuery: self.isBannedListQuery)
        useCase.delegate = self
        return useCase
    }()
    
    private lazy var banUnBanUseCase = BanAndUnBanUseCase(channel: channel)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(GroupChannelMemberCell.self)
        tableView.register(BasicChannelMemberCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    init(channel: GroupChannel, isBannedListQuery: Bool) {
        self.channel = channel
        self.isBannedListQuery = isBannedListQuery
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        useCase.loadNextPage()
    }
    
    private func setupNavigation() {
        title = isBannedListQuery ? "Banned User List" : "Member List"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

}

// MARK: - UITableViewDataSource

extension GroupMemberListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if channel.myRole == .operator {
            let cell: GroupChannelMemberCell = tableView.dequeueReusableCell(for: indexPath)
            cell.update(member: useCase.members[indexPath.row], useCase: banUnBanUseCase)
            cell.delegate = self
            return cell
        } else {
            let cell: BasicChannelMemberCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: useCase.members[indexPath.row])
            return cell
        }
    }

}

// MARK: - UITableViewDelegate

extension GroupMemberListViewController: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            useCase.loadNextPage()
        }
    }
}

// MARK: - GroupChannelMemberCellDelegate

extension GroupMemberListViewController: GroupChannelMemberCellDelegate {
    func groupChannelMemberCell(cell: GroupChannelMemberCell, didUpdateMember: User) {
        useCase.resetAndLoad()
        presentAlert(title: "User", message: "Ban/UnBan successful", closeHandler: nil)
    }
    
    func groupChannelMemberCell(cell: GroupChannelMemberCell, didReceiveError error: Error) {
        presentAlert(error: error)
    }
}

// MARK: - GroupChannelMemberListUseCaseDelegate

extension GroupMemberListViewController: GroupChannelMemberListUseCaseDelegate {
    func groupChannelMemberListUseCase(_ useCase: GroupChannelMemberListUseCase, didReceiveError error: SBError) {
        presentAlert(error: error)
    }
    
    func groupChannelMemberListUseCase(_ useCase: GroupChannelMemberListUseCase, didUpdateMembers members: [User]) {
        tableView.reloadData()
    }
}
