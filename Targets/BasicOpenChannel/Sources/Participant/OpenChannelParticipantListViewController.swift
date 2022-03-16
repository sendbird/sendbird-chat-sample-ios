//
//  OpenChannelParticipantListViewController.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/03/07.
//

import UIKit
import CommonModule
import SendbirdChat

class OpenChannelParticipantListViewController: UIViewController {
    
    private let channel: SBDOpenChannel

    private lazy var useCase: OpenChannelParticipantListUseCase = {
        let useCase = OpenChannelParticipantListUseCase(channel: channel)
        useCase.delegate = self
        return useCase
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(BasicChannelMemberCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    init(channel: SBDOpenChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        useCase.loadNextPage()
    }
    
    private func setupNavigation() {
        title = "Participant List"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
}

// MARK: - UITableViewDataSource

extension OpenChannelParticipantListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BasicChannelMemberCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: useCase.participants[indexPath.row])
        return cell
    }

}

// MARK: - UITableViewDelegate

extension OpenChannelParticipantListViewController: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            useCase.loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - GroupChannelMemberListUseCaseDelegate

extension OpenChannelParticipantListViewController: OpenChannelParticipantListUseCaseDelegate {
    func openChannelParticipantListUseCase(_ useCase: OpenChannelParticipantListUseCase, didReceiveError error: SBDError) {
        presentAlert(error: error)
    }
    
    func openChannelParticipantListUseCase(_ useCase: OpenChannelParticipantListUseCase, didUpdateParticipants participants: [User]) {
        tableView.reloadData()
    }
}
