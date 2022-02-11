//
//  GroupChannelSettingViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import BaseModule

class GroupChannelSettingViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case channelInfo = 0
        case members
    }
    
    enum MemberRow {
        case inviteMember
        case memberInfo
        
        init(rawValue: Int) {
            switch rawValue {
            case 0:
                self = .inviteMember
            default:
                self = .memberInfo
            }
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let channel: SBDGroupChannel
    
    private lazy var inviteMemberUseCase = GroupChannelInviteMemberUseCase(channel: channel)
    
    init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init(nibName: "GroupChannelSettingViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self , forCellReuseIdentifier: "GroupChannelSettingCell")
    }
    
}

// MARK: - UITableViewDataSource

extension GroupChannelSettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .channelInfo:
            return 1
        case .members:
            return (channel.members?.count ?? 0) + 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .channelInfo:
            return "Change Channel Info"
        case .members:
            return "Members"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingCell", for: indexPath)

        switch Section(rawValue: indexPath.section) {
        case .channelInfo:
            cell.textLabel?.text = "\(channel.name)"
            cell.accessoryType = .disclosureIndicator
        case .members:
            switch MemberRow(rawValue: indexPath.row) {
            case .inviteMember:
                cell.textLabel?.text = "👋 Invite a member"
                cell.textLabel?.textAlignment = .center
                cell.accessoryType = .disclosureIndicator
            case .memberInfo:
                cell.textLabel?.text = (channel.members?[indexPath.row - 1] as? SBDUser)?.nickname ?? ""
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .none
            }
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GroupChannelSettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .channelInfo:
            break
        case .members:
            switch MemberRow(rawValue: indexPath.row) {
            case .inviteMember:
                presentInviteMember()
            case .memberInfo:
                break
            }
        default:
            break
        }
    }
    
    private func presentInviteMember() {
        guard let members = channel.members as? [SBDUser] else { return }
        
        let userSelection = UserSelectionViewController(excludeUsers: members) { [weak self] sender, users in
            self?.inviteMemberUseCase.invite(users: users) { result in
                sender.dismiss(animated: true) {
                    switch result {
                    case .success:
                        self?.tableView.reloadData()
                    case .failure(let error):
                        self?.presentAlert(error: error)
                    }
                }
            }
        }
        
        let navigation = UINavigationController(rootViewController: userSelection)
        
        present(navigation, animated: true)
    }
    
}
