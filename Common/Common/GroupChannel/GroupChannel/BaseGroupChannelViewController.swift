//
//  BaseGroupChannelViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/28.
//

import UIKit
import SendBirdSDK

public protocol GroupChannelViewControllerInitializable: UIViewController {
    init(channel: SBDGroupChannel)
}

open class BaseGroupChannelViewController: UIViewController, GroupChannelViewControllerInitializable, UITableViewDelegate {
    
    private let channel: SBDGroupChannel
    
    public private(set) lazy var baseViewModel: BaseGroupChannelViewModel = {
        let viewModel = BaseGroupChannelViewModel(channel: channel)
        viewModel.delegate = self
        return viewModel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupChannelCell") // TO DO: Replace to real cell
        return tableView
    }()
        
    required public init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Group Channels"
        navigationController?.title = "Group"
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        baseViewModel.reloadData()
    }
    
}
    
// MARK: - UITableViewDataSource
    
extension BaseGroupChannelViewController: UITableViewDataSource {
            
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelCell", for: indexPath)
        guard let message = baseViewModel.message(at: indexPath) else {
            return cell
        }
        
        let text = "\(message.sender?.nickname ?? "Unknown"): \(message.message)"
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = text
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = text
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        baseViewModel.numberOfMessages()
    }
    
}

// MARK: - UITableViewDelegate
    
extension BaseGroupChannelViewController {
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

// MARK: - BaseGroupChannelViewModelModelDelegate

extension BaseGroupChannelViewController: BaseGroupChannelViewModelModelDelegate {

    open func baseGroupChannelViewModelDidUpdateMessages(_ viewModel: BaseGroupChannelViewModel) {
        tableView.reloadData()
    }
    
}
