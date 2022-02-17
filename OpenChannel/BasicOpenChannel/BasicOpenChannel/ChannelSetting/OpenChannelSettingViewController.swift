//
//  OpenChannelSettingViewController.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import CommonModule

class OpenChannelSettingViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case channelInfo = 0
        case operators
    }
    
    enum ChannelRow: Int, CaseIterable {
        case name = 0
        case changeName
        case leave
    }
    
    enum OperatorRow {
        case memberInfo(SBDUser)
        
        init(rawValue: Int, members: [SBDUser]) {
            self = .memberInfo(members[rawValue])
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let channel: SBDOpenChannel
    
    private lazy var operatorListUseCase = OpenChannelOperatorListUseCase(channel: channel)
    
    init(channel: SBDOpenChannel) {
        self.channel = channel
        super.init(nibName: "OpenChannelSettingViewController", bundle: Bundle(for: Self.self))
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

extension OpenChannelSettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .channelInfo:
            return ChannelRow.allCases.count
        case .operators:
            return operatorListUseCase.operators.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .channelInfo:
            return "Channel"
        case .operators:
            return "Operators"
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
        case .operators:
            switch OperatorRow(rawValue: indexPath.row, members: operatorListUseCase.operators) {
            case .memberInfo(let member):
                cell.textLabel?.text = member.nickname ?? ""
            }
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension OpenChannelSettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .channelInfo:
            switch ChannelRow(rawValue: indexPath.row) {
            case .name:
                break
            case .changeName:
                break
            case .leave:
                break
            default:
                break
            }
        case .operators:
            break
        default:
            break
        }
    }
        
}
