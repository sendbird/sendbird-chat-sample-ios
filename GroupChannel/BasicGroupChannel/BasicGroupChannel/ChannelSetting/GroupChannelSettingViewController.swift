//
//  GroupChannelSettingViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import CommonModule

class GroupChannelSettingViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case channelInfo = 0
        case members
    }
    
    enum ChannelRow: Int, CaseIterable {
        case name = 0
        case changeName
        case leave
    }
    
    enum MemberRow {
        case memberInfo(SBDUser)
        case inviteMember
        
        init(rawValue: Int, members: [SBDUser]) {
            if rawValue < members.count {
                self = .memberInfo(members[rawValue])
            } else {
                self = .inviteMember
            }
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let channel: SBDGroupChannel
    
    private lazy var settingUseCase = GroupChannelSettingUseCase(channel: channel)
    
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
            return ChannelRow.allCases.count
        case .members:
            return (channel.members?.count ?? 0) + 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .channelInfo:
            return "Channel"
        case .members:
            return "Members"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingCell", for: indexPath)

        cell.textLabel?.textColor = .label
        cell.textLabel?.textAlignment = .left
        cell.accessoryType = .none
        
        switch Section(rawValue: indexPath.section) {
        case .channelInfo:
            switch ChannelRow(rawValue: indexPath.row) {
            case .name:
                cell.textLabel?.text = "\(channel.name)"
            case .changeName:
                cell.textLabel?.text = "Change Channel Name"
                cell.accessoryType = .disclosureIndicator
            case .leave:
                cell.textLabel?.textColor = .systemRed
                cell.textLabel?.text = "Leave Channel"
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
        case .members:
            switch MemberRow(rawValue: indexPath.row, members: settingUseCase.members) {
            case .memberInfo(let member):
                cell.textLabel?.text = member.nickname ?? ""
            case .inviteMember:
                cell.textLabel?.text = "👋 Invite a member"
                cell.accessoryType = .disclosureIndicator
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
            switch ChannelRow(rawValue: indexPath.row) {
            case .name:
                break
            case .changeName:
                presentChangeChannelNameAlert()
            case .leave:
                presentLeaveChannelAlert()
            default:
                break
            }
        case .members:
            switch MemberRow(rawValue: indexPath.row, members: settingUseCase.members) {
            case .memberInfo:
                break
            case .inviteMember:
                presentInviteMember()
            }
        default:
            break
        }
    }
    
    private func presentInviteMember() {
        let userSelection = UserSelectionViewController(channel: channel) { [weak self] sender, users in
            self?.settingUseCase.invite(users: users) { result in
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
    
    private func presentChangeChannelNameAlert() {
        presentTextFieldAlert(title: "Change channel name", message: nil, defaultTextFieldMessage: channel.name) { [weak self] editedName in
            self?.settingUseCase.updateChannelName(editedName) { result in
                switch result {
                case .success:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        }
    }
    
    private func presentLeaveChannelAlert() {
        let alert = UIAlertController(title: "Leave Channel", message: "Are you sure you want to leave the channel?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            self?.settingUseCase.leaveChannel { result in
                switch result {
                case .success:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        })
        
        present(alert, animated: true)
    }

}
