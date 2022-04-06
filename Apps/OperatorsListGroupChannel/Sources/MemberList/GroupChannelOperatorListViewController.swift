//
//  GroupChannelOperatorListViewController.swift
//  OperatorsListGroupChannel
//
//  Created by Yogesh Veeraraj on 03.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChat

class GroupChannelOperatorListViewController: UITableViewController {
    
    private let channel: GroupChannel

    private lazy var useCase: GroupChannelOperatorListUseCase = {
        let useCase = GroupChannelOperatorListUseCase(channel: channel)
        useCase.delegate = self
        return useCase
    }()
        
    init(channel: GroupChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BasicChannelMemberCell.self)
        setupNavigation()
        useCase.loadNextPage()
    }
    
    private func setupNavigation() {
        title = "Operator List"
    }
    
}

extension GroupChannelOperatorListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.operators.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BasicChannelMemberCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: useCase.operators[indexPath.row])
        return cell
    }

}

// MARK: - UITableViewDelegate

extension GroupChannelOperatorListViewController {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            useCase.loadNextPage()
        }
    }
}

// MARK: - GroupChannelOperatorListUseCaseDelegate

extension GroupChannelOperatorListViewController: GroupChannelOperatorListUseCaseDelegate {
    
    func groupChannelOperatorListUseCase(_ useCase: GroupChannelOperatorListUseCase, didReceiveError error: SBError) {
        presentAlert(error: error)
    }
    
    func groupChannelOperatorListUseCase(_ useCase: GroupChannelOperatorListUseCase, didUpdateOperators operators: [User]) {
        tableView.reloadData()
    }
}
