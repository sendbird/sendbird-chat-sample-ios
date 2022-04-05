//
//  OpenChannelListViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule
import SendbirdChatSDK

final class OpenChannelListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OpenChannelListCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        return tableView
    }()
    
    private lazy var createChannelBarButton = UIBarButtonItem(
        title: "Create",
        style: .plain,
        target: self,
        action: #selector(didTouchCreatChannelButton)
    )
    
    private lazy var useCase: OpenChannelListUseCase = {
        let useCase = OpenChannelListUseCase()
        useCase.delegate = self
        return useCase
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "OpenChannel"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        setupNavigation()
        
        useCase.reloadChannels()
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = createChannelBarButton
    }
    
    @objc private func refreshTableView() {
        useCase.reloadChannels()
    }
    
    @objc private func didTouchCreatChannelButton() {
        let createGroupChannelViewController = CreateOpenChannelViewController { [weak self] _ in
            self?.useCase.reloadChannels()
        }
        let navigation = UINavigationController(rootViewController: createGroupChannelViewController)
        
        present(navigation, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension OpenChannelListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelListCell", for: indexPath)
        let channel = useCase.channels[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = channel.name
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = channel.name
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension OpenChannelListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = useCase.channels[indexPath.row]
        
        useCase.enterChannel(channel) { [weak self] result in
            switch result {
            case .success:
                let channelViewController = OpenChannelViewController(channel: channel)
                channelViewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(channelViewController, animated: true)
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leaveAction = UIContextualAction(style: .destructive, title: "Leave") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let channel = self.useCase.channels[indexPath.row]
            
            self.useCase.exitChannel(channel) { result in
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

}

// MARK: - OpenChannelListUseCaseDelegate

extension OpenChannelListViewController: OpenChannelListUseCaseDelegate {
    
    func openChannelListUseCase(_ openChannelListUseCase: OpenChannelListUseCase, didReceiveError error: SBError) {
        DispatchQueue.main.async { [weak self] in
            self?.presentAlert(error: error)
        }
    }
    
    func openChannelListUseCase(_ openChannelListUseCase: OpenChannelListUseCase, didUpdateChannels channels: [OpenChannel]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
}
