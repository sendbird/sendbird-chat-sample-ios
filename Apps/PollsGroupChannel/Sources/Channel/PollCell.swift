//
//  PollCell.swift
//  PollsGroupChannel
//
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol PollCellDelegate: AnyObject {
    func pollOptionVoted(_ pollCell: PollCell, _ poll: Poll, _ optionVoted: PollOption)
    func pollOptionLongPressed(_ pollCell: PollCell, _ poll: Poll, _ optionVoted: PollOption)
    func addOptionToPoll(_ pollCell: PollCell, _ poll: Poll)
    func closePoll(_ pollCell: PollCell, _ poll: Poll)
}

class PollCell: UITableViewCell {

    private lazy var pollLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()

    private lazy var addOptionButton: UIButton = {
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

    private var poll: Poll? = nil
    var delegate: PollCellDelegate? = nil

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
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: pollLabel.bottomAnchor, constant: 10),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }


    func configure(_ poll: Poll) {
        self.poll = poll
        var pollTitle = poll.title
        if poll.status == .closed {
            pollTitle = "\(pollTitle) - closed"
        }
        if poll.status == .open && poll.closeAt > 0 {
            pollTitle = "\(pollTitle)\nClose At \(Date(timeIntervalSince1970: TimeInterval(poll.closeAt)).sbu_toString(format: .yyyyMMddhhmm))"
        }
        pollLabel.text = pollTitle
        closeButton.isHidden = !(SendbirdChat.getCurrentUser()?.userId == poll.createdBy && poll.status == .open)
        poll.options.forEach { option in
            let optionView = PollOptionView()
            optionView.configure(option)
            optionView.delegate = self
            optionsStackView.addArrangedSubview(optionView)
        }
        if poll.allowUserSuggestion && poll.status == .open {
            optionsStackView.addArrangedSubview(addOptionButton)
        }
        optionsStackView.layoutIfNeeded()
    }

    override func prepareForReuse() {
        pollLabel.text = nil
        poll = nil
        optionsStackView.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
    }

    @objc private func closePoll() {
        guard let poll = poll, let delegate = delegate else {
            return
        }
        delegate.closePoll(self, poll)
    }

    @objc private func addOptionToPoll() {
        guard let poll = poll, let delegate = delegate else {
            return
        }
        delegate.addOptionToPoll(self, poll)
    }
}

extension PollCell: PollOptionViewDelegate {
    func pollOptionTapped(_ pollOptionView: PollOptionView, _ pollOption: PollOption) {
        guard let poll = poll else {
            return
        }
        delegate?.pollOptionVoted(self, poll, pollOption)
    }

    func pollOptionLongPressed(_ pollOptionView: PollOptionView, _ pollOption: PollOption) {
        guard let poll = poll else {
            return
        }
        delegate?.pollOptionLongPressed(self, poll, pollOption)
    }
}