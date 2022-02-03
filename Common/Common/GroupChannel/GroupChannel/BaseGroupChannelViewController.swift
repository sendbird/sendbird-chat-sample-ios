//
//  BaseGroupChannelViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/28.
//

import UIKit
import SendBirdSDK

open class BaseGroupChannelViewController<ViewModel: BaseGroupChannelViewModel>:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    BaseGroupChannelViewModelModelDelegate {
    
    open var viewModel: ViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupChannelCell") // TO DO: Replace to real cell
        return tableView
    }()
    
    required public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = viewModel.channel.name
        
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
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelCell", for: indexPath)
        guard let message = viewModel.message(at: indexPath),
              let cellText = viewModel.cellText(for: message) else {
                  return cell
              }
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = cellText
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = cellText
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfMessages()
    }
    
    // MARK: - UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - BaseGroupChannelViewModelModelDelegate
    
    open func groupChannelViewModelDidUpdateMessages(_ viewModel: BaseGroupChannelViewModel) {
        tableView.reloadData()
    }
    
    public func groupChannelViewModel(_ viewModel: BaseGroupChannelViewModel, didReceiveError error: SBDError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
}
