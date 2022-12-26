//
//  PollCell.swift
//  PollsGroupChannel
//
//  Created by Mihai Moisanu on 23.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol PollCellDelegate : AnyObject{
    func pollOptionVoted(_ pollCell:PollCell, _ poll:Poll, _ optionVoted: PollOption)
    func addOptionToPoll(_ pollCell:PollCell, _ poll:Poll)
    func closePoll(_ pollCell:PollCell, _ poll:Poll)
}

class PollCell : UITableViewCell{
    
    private lazy var pollLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var optionsTableView:UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PollOptionCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40.0
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var addOptionButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Option", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(addOptionToPoll), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(closePoll), for: .touchUpInside)
        return button
    }()
    
    private var poll:Poll? = nil
    var delegate:PollCellDelegate? = nil
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(pollLabel)
        NSLayoutConstraint.activate([
            pollLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            pollLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        contentView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: pollLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ]
        )
        contentView.addSubview(optionsStackView)
        optionsStackView.addArrangedSubview(optionsTableView)
        optionsStackView.addSubview(optionsTableView)
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: pollLabel.bottomAnchor, constant: 10),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            optionsTableView.widthAnchor.constraint(equalTo: optionsStackView.widthAnchor)
        ])
    }
    
    
    func configure(_ poll:Poll){
        self.poll = poll
        var pollTitle = poll.title
        if poll.status == .closed{
            pollTitle = "\(pollTitle) - closed"
        }
        pollLabel.text = pollTitle
        closeButton.isHidden = !(SendbirdChat.getCurrentUser()?.userId == poll.createdBy && poll.status == .open)
        optionsTableView.reloadData()
        if poll.allowUserSuggestion && poll.status == .open{
            optionsStackView.addArrangedSubview(addOptionButton)
            NSLayoutConstraint.activate([
                addOptionButton.widthAnchor.constraint(equalTo: optionsStackView.widthAnchor, multiplier: 0.5),
                addOptionButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        optionsStackView.layoutIfNeeded()
    }
    
    var heightConstraint :NSLayoutConstraint? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let multiplier:CGFloat
        if poll?.status == .open{
            multiplier = 1.4
        }else{
            multiplier = 1
        }
        heightConstraint?.isActive = false
        heightConstraint = optionsStackView.heightAnchor.constraint(equalToConstant: optionsTableView.contentSize.height * multiplier)
        heightConstraint?.isActive = true
    }
    
    override func prepareForReuse() {
        pollLabel.text = nil
        poll = nil
        addOptionButton.removeFromSuperview()
        optionsTableView.reloadData()
        heightConstraint?.isActive = false
    }
    
    @objc private func closePoll(){
        guard let poll = poll, let delegate  = delegate else { return }
        delegate.closePoll(self, poll)
    }
    
    @objc private func addOptionToPoll(){
        guard let poll = poll, let delegate  = delegate else { return }
        delegate.addOptionToPoll(self, poll)
    }
}

extension PollCell : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let poll = poll, let delegate = delegate else { return }
        delegate.pollOptionVoted(self, poll, poll.options[indexPath.row])
    }
}

extension PollCell: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poll?.options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let options = poll?.options else { return tableView.dequeueReusableCell(for: indexPath)}
        let cell: PollOptionCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(options[indexPath.row])
        return cell
    }
}

class PollOptionCell: UITableViewCell {
    
    private lazy var optionName:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var optionCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        contentView.addSubview(optionName)
        contentView.addSubview(optionCount)
        NSLayoutConstraint.activate([
            optionName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            optionName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            optionName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            optionCount.centerYAnchor.constraint(equalTo: optionName.centerYAnchor),
            optionCount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(_ option:PollOption){
        optionName.text = option.text
        if option.voteCount > 0 {
            optionCount.text = "+\(option.voteCount)"
        }else{
            optionCount.text = ""
        }
    }
}
