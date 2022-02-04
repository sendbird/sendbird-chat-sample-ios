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
    func baseGroupChannelListViewModel(_ viewModel: BaseGroupChannelListViewModel, didUpdateTotalUnreadMessageCount totalUnreadMessageCount: Int)
}

public class BaseGroupChannelListViewModel: NSObject {
    
    weak var delegate: BaseGroupChannelListViewModelDelegate?
    
    private(set) var channels: [SBDGroupChannel] = []
        
    private lazy var channelListQuery: SBDGroupChannelListQuery = createGroupChannelListQuery()
    
    public override init() {
        super.init()
        SBDMain.add(self as SBDChannelDelegate, identifier: description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: description)
        SBDMain.add(self as SBDUserEventDelegate, identifier: description)
    }
    
    deinit {
        SBDMain.removeChannelDelegate(forIdentifier: description)
        SBDMain.removeConnectionDelegate(forIdentifier: description)
        SBDMain.removeUserEventDelegate(forIdentifier: description)
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
    
    public func updateTotalUnreadMessageCount() {
        SBDMain.getTotalUnreadMessageCount { [weak self] unreadCount, error in
            if error != nil {
                return
            }
            
            guard let self = self else { return }

            self.delegate?.baseGroupChannelListViewModel(self, didUpdateTotalUnreadMessageCount: Int(unreadCount))
        }
    }
    
    private func createGroupChannelListQuery() -> SBDGroupChannelListQuery {
        let channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery() ?? SBDGroupChannelListQuery.init(dictionary: [:])
        channelListQuery.order = .latestLastMessage
        channelListQuery.limit = 20
        channelListQuery.includeEmptyChannel = true
        return channelListQuery
    }
    
}

// MARK: - SBDChannelDelegate

extension BaseGroupChannelListViewModel: SBDChannelDelegate {
    
}

// MARK: - SBDConnectionDelegate

extension BaseGroupChannelListViewModel: SBDConnectionDelegate {
    
}

// MARK: - SBDUserEventDelegate

extension BaseGroupChannelListViewModel: SBDUserEventDelegate {
    
    public func didUpdateTotalUnreadMessageCount(_ totalCount: Int32, totalCountByCustomType: [String : NSNumber]?) {
        delegate?.baseGroupChannelListViewModel(self, didUpdateTotalUnreadMessageCount: Int(totalCount))
    }
    
}
