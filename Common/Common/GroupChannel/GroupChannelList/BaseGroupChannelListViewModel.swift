//
//  BaseGroupChannelListViewModel.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/27.
//

import Foundation
import SendBirdSDK

protocol BaseGroupChannelListViewModelDelegate: AnyObject {
    func baseGroupChannelListViewModelEndLoading(_ viewModel: BaseGroupChannelListViewModel)
}

public class BaseGroupChannelListViewModel: NSObject {
    
    weak var delegate: BaseGroupChannelListViewModelDelegate?
    
    private(set) var channels: [SBDGroupChannel] = []
    
    private let identifier = UUID().uuidString
    
    private lazy var channelListQuery: SBDGroupChannelListQuery = createGroupChannelListQuery()
    
    public override init() {
        super.init()
        SBDMain.add(self as SBDChannelDelegate, identifier: identifier)
        SBDMain.add(self as SBDConnectionDelegate, identifier: identifier)
    }
    
    public func reloadData() {
        channelListQuery = createGroupChannelListQuery()
        
        channelListQuery.loadNextPage { [weak self] channels, error in
            if error != nil {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.delegate?.baseGroupChannelListViewModelEndLoading(self)
                }
                return
            }
            
            guard let channels = channels else { return }
            
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.channels = channels
                self.delegate?.baseGroupChannelListViewModelEndLoading(self)
            }
        }
    }
    
    public func loadNextPage() {
        guard channelListQuery.hasNext == false else {
            return
        }
        
        channelListQuery.loadNextPage { [weak self] channels, error in
            if error != nil {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.delegate?.baseGroupChannelListViewModelEndLoading(self)
                }
                return
            }
            
            guard let channels = channels else { return }
            
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.channels.append(contentsOf: channels)
                self.delegate?.baseGroupChannelListViewModelEndLoading(self)
            }
        }
    }
    
    private func createGroupChannelListQuery() -> SBDGroupChannelListQuery {
        let channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery() ?? SBDGroupChannelListQuery.init(dictionary: [:])
        channelListQuery.order = .latestLastMessage
        channelListQuery.limit = 20
        channelListQuery.includeEmptyChannel = true
        return channelListQuery
    }

//    func updateTotalUnreadMessageCountBadge() {
//        SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
//            guard let navigationController = self.navigationController else { return }
//            if error != nil {
//                navigationController.tabBarItem.badgeValue = nil
//
//                return
//            }
//
//            if unreadCount > 0 {
//                navigationController.tabBarItem.badgeValue = String(format: "%ld", unreadCount)
//            }
//            else {
//                navigationController.tabBarItem.badgeValue = nil
//            }
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
//            SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
//                guard let navigationController = self.navigationController else { return }
//                if error != nil {
//                    navigationController.tabBarItem.badgeValue = nil
//                    return
//                }
//
//                if unreadCount > 0 {
//                    navigationController.tabBarItem.badgeValue = String(format: "%ld", unreadCount)
//                }
//                else {
//                    navigationController.tabBarItem.badgeValue = nil
//                }
//            }
//        }
//    }
    
}

// MARK: - SBDChannelDelegate

extension BaseGroupChannelListViewModel: SBDChannelDelegate {
    
}

// MARK: - SBDConnectionDelegate

extension BaseGroupChannelListViewModel: SBDConnectionDelegate {
    
}
