//
//  CreatePollViewController.swift
//  PollsGroupChannel
//
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class CreatePollViewController : UIViewController{
    
    private lazy var pollTitleContainer:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var pollTitleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 14)
        textField.placeholder = "Poll title"
        return textField
    }()
    
    private lazy var optionsLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Options"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var optionsCotainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return stackView
    }()
    
    private lazy var addOptionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Option", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(addOptionView), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeAtButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close at", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(openTimeSelector), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeAtLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var multipleVoteLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Allow multiple votes"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var multipleVotesSwitch:UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()
    
    private lazy var userSuggestionLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Allow user suggestions"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var userSuggestionSwitch:UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()
    
    private lazy var createPollButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create poll", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(createPoll), for: .touchUpInside)
        return button
    }()
    
    private var closeAtDate:Date? = nil
    private let pollUseCase:PollUseCase
    
    init(channel:GroupChannel){
        pollUseCase = PollUseCase(channel: channel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create Poll"
        
        view.backgroundColor = .systemBackground
        
        pollTitleContainer.addSubview(pollTitleTextField)
        NSLayoutConstraint.activate([
            pollTitleTextField.leadingAnchor.constraint(equalTo: pollTitleContainer.leadingAnchor, constant: 20),
            pollTitleTextField.trailingAnchor.constraint(equalTo: pollTitleContainer.trailingAnchor, constant: -20),
            pollTitleTextField.topAnchor.constraint(equalTo: pollTitleContainer.topAnchor),
            pollTitleTextField.bottomAnchor.constraint(equalTo: pollTitleContainer.bottomAnchor),
            pollTitleTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        view.addSubview(pollTitleContainer)
        
        NSLayoutConstraint.activate([
            pollTitleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pollTitleContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            pollTitleContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            pollTitleContainer.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(optionsLabel)
        NSLayoutConstraint.activate([
            optionsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            optionsLabel.topAnchor.constraint(equalTo: pollTitleContainer.bottomAnchor, constant: 10),
        ])
        
        view.addSubview(optionsCotainerView)
        NSLayoutConstraint.activate([
            optionsCotainerView.topAnchor.constraint(equalTo: optionsLabel.bottomAnchor),
            optionsCotainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            optionsCotainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
        ])
        
        view.addSubview(addOptionButton)
        NSLayoutConstraint.activate([
            addOptionButton.topAnchor.constraint(equalTo: optionsCotainerView.bottomAnchor, constant: 10),
            addOptionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            addOptionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            addOptionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(closeAtButton)
        view.addSubview(closeAtLabel)
        NSLayoutConstraint.activate([
            closeAtButton.topAnchor.constraint(equalTo: addOptionButton.bottomAnchor, constant: 5),
            closeAtButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            closeAtButton.heightAnchor.constraint(equalToConstant: 40),
            closeAtButton.widthAnchor.constraint(equalToConstant: 100),
            closeAtLabel.centerYAnchor.constraint(equalTo: closeAtButton.centerYAnchor),
            closeAtLabel.leadingAnchor.constraint(equalTo: closeAtButton.trailingAnchor, constant: 10),
            closeAtLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 5)
        ])
        
        view.addSubview(userSuggestionLabel)
        view.addSubview(multipleVoteLabel)
        view.addSubview(multipleVotesSwitch)
        view.addSubview(userSuggestionSwitch)
        
        NSLayoutConstraint.activate([
            multipleVotesSwitch.topAnchor.constraint(equalTo: closeAtButton.bottomAnchor, constant: 10),
            multipleVotesSwitch.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            userSuggestionSwitch.topAnchor.constraint(equalTo: multipleVotesSwitch.bottomAnchor, constant: 10),
            userSuggestionSwitch.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            userSuggestionLabel.centerYAnchor.constraint(equalTo: userSuggestionSwitch.centerYAnchor),
            userSuggestionLabel.leadingAnchor.constraint(equalTo: userSuggestionSwitch.trailingAnchor, constant: 10),
            multipleVoteLabel.centerYAnchor.constraint(equalTo: multipleVotesSwitch.centerYAnchor),
            multipleVoteLabel.leadingAnchor.constraint(equalTo: multipleVotesSwitch.trailingAnchor, constant: 10)
        ])
        
        view.addSubview(createPollButton)
        
        NSLayoutConstraint.activate([
            createPollButton.topAnchor.constraint(equalTo: userSuggestionSwitch.bottomAnchor, constant: 10),
            createPollButton.heightAnchor.constraint(equalToConstant: 40),
            createPollButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            createPollButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25)
        ])
        
        addOptionView()
        addOptionView()
    }
    
    
    @objc private func addOptionView(){
        let pollOptionView = CreatePollOptionView()
        pollOptionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        optionsCotainerView.addArrangedSubview(pollOptionView)
    }
    
    @objc private func openTimeSelector(){
        if(closeAtDate != nil){
            closeAtDate = nil
            closeAtLabel.text = ""
            closeAtButton.setTitle("Close at", for: .normal)
            return
        }
        let timePickerController = UIAlertController(title: "Close at", onDateSelected: { [weak self] timeStamp in
            self?.closeAtDate = timeStamp
            self?.closeAtLabel.text = "\(timeStamp.sbu_toString(format: .yyyyMMddhhmm))"
            self?.closeAtButton.setTitle("Clear", for:   .normal)
        })
        present(timePickerController, animated: true)
    }
    
    @objc private func createPoll(){
        guard let pollTitle = pollTitleTextField.text else { return }
        let pollOptions:[String] = optionsCotainerView.subviews.map( {view  in
            let optionView = view as! CreatePollOptionView
            return optionView.getOptionName()!
        }).filter({!$0.isEmpty})
        let allowMultipleVotes = multipleVotesSwitch.isOn
        let allowUserSugestions = userSuggestionSwitch.isOn
        var closeAt:Int64? = nil
        if let timestamp = closeAtDate?.timeIntervalSince1970{
            closeAt = Int64(timestamp)
        }
        pollUseCase.createPoll(pollTitle: pollTitle, pollOptions: pollOptions, closeAt: closeAt, allowUserSuggestions: allowUserSugestions, allowMultipleVotes: allowMultipleVotes){ [weak self] error in
            
            if let error = error{
                self?.presentAlert(error: error)
                return
            }
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
