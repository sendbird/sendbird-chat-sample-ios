//
//  BaseGroupChannelViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import UIKit

open class BaseGroupChannelListViewController<ChannelViewController, ChannelViewModel>:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    BaseGroupChannelListViewModelDelegate
where ChannelViewController: BaseGroupChannelViewController<ChannelViewModel>,
      ChannelViewModel: BaseGroupChannelViewModel {
    
    private lazy var viewModel: BaseGroupChannelListViewModel = {
        let viewModel = BaseGroupChannelListViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupChannelListCell") // TO DO: Replace to real cell
        return tableView
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "Group"
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
        
        viewModel.reloadData()
    }
    
    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.channels.count
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = viewModel.channels[indexPath.row]
        
        navigationController?.pushViewController(ChannelViewController(viewModel: .init(channel: channel)), animated: true)
    }
    
    // MARK: - BaseGroupChannelListViewModelDelegate

    func baseGroupChannelListViewModelEndLoading(_ viewModel: BaseGroupChannelListViewModel) {
        tableView.reloadData()
    }
    
}
