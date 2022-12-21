//
//  ScheduledMessagesViewController.swift
//  ScheduledMessagesGroupChannel
//
//  Created by Mihai Moisanu on 20.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import CommonModule

class ScheduledMessagesViewController : UIViewController{
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ScheduledMessageCell.self)
        tableView.register(ScheduledFileMessageCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140.0
        tableView.delegate = self
        tableView.dataSource = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        return tableView
    }()
    
    let channel : GroupChannel
    
    public private(set) lazy var scheduledMesssagesUseCase = ScheduleMesssageUseCase(channel: channel)
    private var messages = [BaseMessage]()
    
    init(channel: GroupChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        setupNavigation()
        loadMessages()
    }
    
    private func setupNavigation() {
        title = "ScheduledMessages \(channel.name)"
    }
    
    func loadMessages(){
        scheduledMesssagesUseCase.getScheduledMessages(onMessageRetrieved: {[weak self] result in
            switch result {
            case .success(let scheduledMessages):
                guard let self = self else { return }
                self.messages = scheduledMessages
                self.tableView.reloadData()
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        })
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer){
        guard sender.state == .began else { return }
        
        let touchPoint = sender.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }
        
        let message = messages[indexPath.row]
        
        handleLongPress(for: message)
    }
}

extension ScheduledMessagesViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ScheduledMessagesViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if let fileMessage = message as? FileMessage{
            let cell: ScheduledFileMessageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: fileMessage)
            return cell
        }else{
            let cell: ScheduledMessageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: message)
            return cell
        }
    }
}


