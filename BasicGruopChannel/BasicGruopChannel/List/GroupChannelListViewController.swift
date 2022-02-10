//
//  GroupChannelListViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import BaseModule
import SendBirdSDK

final class GroupChannelListViewController: UIViewController {
    
    private lazy var viewModel: GroupChannelListViewModel = {
        let viewModel = GroupChannelListViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    @IBOutlet private weak var tableView: UITableView!
    
    init() {
        super.init(nibName: "GroupChannelListViewController", bundle: Bundle(for: Self.self))
        title = "GroupChannel"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        viewModel.reloadChannels()
        viewModel.loadTotalUnreadMessageCount()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupChannelListCell")
    }
        
}

// MARK: - UITableViewDataSource

extension GroupChannelListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelListCell", for: indexPath)
        let channel = viewModel.channels[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = channel.name
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = channel.name
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension GroupChannelListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = viewModel.channels[indexPath.row]
        let channelViewController = GroupChannelViewController(channel: channel)
        channelViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(channelViewController, animated: true)
    }

}

// MARK: - GroupChannelListDelegate

extension GroupChannelListViewController: GroupChannelListViewModelDelegate {

    func groupChannelListViewModel(_ groupChannelListViewModel: GroupChannelListViewModel, didUpdateChannels: [SBDGroupChannel]) {
        tableView.reloadData()
    }

    func groupChannelListViewModel(_ groupChannelListViewModel: GroupChannelListViewModel, didUpdateUnreadMessageCount unreadMessageCount: Int) {
        navigationController?.tabBarItem.badgeValue = unreadMessageCount > 0 ? "\(unreadMessageCount)" : nil
    }
    
    func groupChannelListViewModel(_ groupChannelListViewModel: GroupChannelListViewModel, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
        
}
