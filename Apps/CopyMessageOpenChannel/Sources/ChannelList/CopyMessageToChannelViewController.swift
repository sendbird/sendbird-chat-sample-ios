//
//  OpenChannelSelectionViewController.swift
//  CopyMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 28.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChatSDK

protocol CopyMessageToChannelViewControllerDelegate: AnyObject {
    func didSelect(channel: OpenChannel, forMessage message: BaseMessage)
}

final class CopyMessageToChannelViewController: UIViewController {
    
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
    
    weak var delegate: CopyMessageToChannelViewControllerDelegate?
    
    private let message: BaseMessage
        
    private lazy var useCase: OpenChannelListUseCase = {
        let useCase = OpenChannelListUseCase()
        useCase.delegate = self
        return useCase
    }()
    
    init(with message: BaseMessage) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
        title = "Choose Channel"
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
        
        useCase.reloadChannels()
    }
        
    @objc private func refreshTableView() {
        useCase.reloadChannels()
    }
}

// MARK: - UITableViewDataSource

extension CopyMessageToChannelViewController: UITableViewDataSource {
    
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

extension CopyMessageToChannelViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channel = useCase.channels[indexPath.row]
        delegate?.didSelect(channel: channel, forMessage: message)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - OpenChannelListUseCaseDelegate

extension CopyMessageToChannelViewController: OpenChannelListUseCaseDelegate {
    
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
