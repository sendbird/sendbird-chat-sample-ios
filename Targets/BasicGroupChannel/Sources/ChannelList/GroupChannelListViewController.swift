//
//  GroupChannelListViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule
import SendbirdChat

final class GroupChannelListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var createChannelBarButton = UIBarButtonItem(
        title: "Create",
        style: .plain,
        target: self,
        action: #selector(didTouchCreatChannelButton)
    )
    
    private lazy var useCase: GroupChannelListUseCase = {
        let useCase = GroupChannelListUseCase()
        useCase.delegate = self
        return useCase
    }()
    
    private lazy var timestampStorage = TimestampStorage()
    
    init() {
        super.init(nibName: "GroupChannelListViewController", bundle: Bundle(for: Self.self))
        title = "GroupChannel"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        useCase.reloadChannels()
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = createChannelBarButton
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GroupChannelListCell.self)
    }
    
    @objc private func didTouchCreatChannelButton() {
        let userSelectionViewController = UserSelectionViewController(didSelectUsers: { sender, users in
            let createGroupChannelViewController = CreateGroupChannelViewController(users: users)
            sender.navigationController?.pushViewController(createGroupChannelViewController, animated: true)
        })
        let navigation = UINavigationController(rootViewController: userSelectionViewController)
        
        present(navigation, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension GroupChannelListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupChannelListCell = tableView.dequeueReusableCell(for: indexPath)
        let channel = useCase.channels[indexPath.row]
        
        cell.configure(with: channel)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension GroupChannelListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = useCase.channels[indexPath.row]
        let channelViewController = GroupChannelViewController(channel: channel, timestampStorage: timestampStorage)
        channelViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(channelViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leaveAction = UIContextualAction(style: .destructive, title: "Leave") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let channel = self.useCase.channels[indexPath.row]
            
            self.useCase.leaveChannel(channel) { result in
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }

        return UISwipeActionsConfiguration(actions: [leaveAction])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            useCase.loadNextPage()
        }
    }

}

// MARK: - GroupChannelListUseCaseDelegate

extension GroupChannelListViewController: GroupChannelListUseCaseDelegate {
    
    func groupChannelListUseCase(_ groupChannelListUseCase: GroupChannelListUseCase, didReceiveError error: SBError) {
        DispatchQueue.main.async { [weak self] in
            self?.presentAlert(error: error)
        }
    }
    
    func groupChannelListUseCase(_ groupChannelListUseCase: GroupChannelListUseCase, didUpdateChannels: [SBDGroupChannel]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}
