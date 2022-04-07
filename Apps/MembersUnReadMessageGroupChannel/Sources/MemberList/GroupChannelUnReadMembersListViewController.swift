//
//  GroupChannelUnReadMembersListViewController.swift
//  MembersUnReadMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 03.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChatSDK

class GroupChannelUnReadMembersListViewController: UITableViewController {
    
    private let channel: GroupChannel
    private let message: BaseMessage

    private lazy var useCase = MembersUnReadMessageUseCase(channel: channel)
    
    private var members: [Member] {
        return useCase.getUnReadMembers(for: message)
    }
        
    init(channel: GroupChannel, message: BaseMessage) {
        self.channel = channel
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        tableView.register(BasicChannelMemberCell.self)
    }
    
    private func setupNavigation() {
        title = "Message Info"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BasicChannelMemberCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: members[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return members.count == 0 ? "No members read the message" : "UnRead By"
    }
    
}
