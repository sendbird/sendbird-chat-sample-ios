//
//  GroupChannelMemberCell.swift
//  AddRemoveOperatorsGroupChannel
//
//  Created by Yogesh Veeraraj on 07.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChat

class GroupChannelMemberCell: BasicChannelMemberCell {
    
    private var useCase: GroupChannelListUseCase?
    private var user: User?
    
    private lazy var addRemoveOperatorButton: UIButton = {
        let button = UIButton()
        button.addAction(#selector(addRemoveOperatorAction), for: .touchUpInside)
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        useCase = nil
        user = nil
    }
    
    func update(user: User, useCase: GroupChannelListUseCase) {
        self.useCase = useCase
        self.user = user
        configure(with: user)
    }
    
    func addRemoveOperatorAction() {
        
    }
    
}
