//
//  GroupChannelBannedMemberListViewController.swift
//  MutedAndBannedUsersListGroupChannel
//
//  Created by Yogesh Veeraraj on 19.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//
import UIKit
import CommonModule
import SendbirdChatSDK

class GroupChannelBannedMemberListViewController: UITableViewController {
    
    private let channel: GroupChannel

    private lazy var useCase: BannedMembersListUseCase = {
        let useCase = BannedMembersListUseCase(channel: channel)
        useCase.delegate = self
        return useCase
    }()
        
    init(channel: GroupChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BasicChannelMemberCell.self)
        setupNavigation()
        useCase.loadNextPage()
    }
    
    private func setupNavigation() {
        title = "Banned User List"
    }
    
}

extension GroupChannelBannedMemberListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BasicChannelMemberCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: useCase.members[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return useCase.members.count == 0 ? "No Banned Users" : "Banned Users"
    }

}

// MARK: - UITableViewDelegate

extension GroupChannelBannedMemberListViewController {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            useCase.loadNextPage()
        }
    }
}

// MARK: - BannedMembersListUseCaseDelegate

extension GroupChannelBannedMemberListViewController: BannedMembersListUseCaseDelegate {
    
    func groupChannelBannedMembersListUseCase(_ useCase: BannedMembersListUseCase, didReceiveError error: SBError) {
        presentAlert(error: error)
    }
    
    func groupChannelBannedMembersListUseCase(_ useCase: BannedMembersListUseCase, didUpdateMembers members: [User]) {
        tableView.reloadData()
    }
}
