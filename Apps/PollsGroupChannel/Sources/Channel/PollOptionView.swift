//
// Copyright (c) 2022 Sendbird. All rights reserved.
//

import Foundation
import UIKit
import SendbirdChatSDK

protocol PollOptionViewDelegate: AnyObject {
    func pollOptionTapped(_ pollOptionView: PollOptionView, _ pollOption: PollOption)
    func pollOptionLongPressed(_ pollOptionView:PollOptionView, _ pollOption:PollOption)
}

class PollOptionView: UIControl {

    private lazy var optionName: UILabel = {
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

    weak var delegate: PollOptionViewDelegate? = nil
    private var pollOption: PollOption? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        clipsToBounds = true

        addSubview(optionName)
        addSubview(optionCount)

        NSLayoutConstraint.activate([
            optionName.topAnchor.constraint(equalTo: topAnchor),
            optionName.bottomAnchor.constraint(equalTo: bottomAnchor),
            optionName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            optionCount.centerYAnchor.constraint(equalTo: optionName.centerYAnchor),
            optionCount.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            heightAnchor.constraint(equalToConstant: 40)
        ])

        addTarget(self, action: #selector(onOptionClicked), for: .touchUpInside)
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onOptionLongClicked)))
    }

    func configure(_ pollOption: PollOption) {
        self.pollOption = pollOption
        optionName.text = pollOption.text
        if pollOption.voteCount > 0 {
            optionCount.text = "+\(pollOption.voteCount)"
        } else {
            optionCount.text = ""
        }
    }

    @objc private func onOptionClicked() {
        guard let pollOption = pollOption else {
            return
        }
        delegate?.pollOptionTapped(self, pollOption)
    }

    @objc private func onOptionLongClicked(){
        guard let pollOption = pollOption else {
            return
        }
        delegate?.pollOptionLongPressed(self, pollOption)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}