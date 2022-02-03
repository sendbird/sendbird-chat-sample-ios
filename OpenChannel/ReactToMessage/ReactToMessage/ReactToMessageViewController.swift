//
//  ReactToMessageViewController.swift
//  ReactToMessage
//
//  Created by Ernest Hong on 2022/02/03.
//

import UIKit
import Common
import SendBirdSDK

final class ReactToMessageViewController: BaseGroupChannelViewController<ReactToMessageViewModel> {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        guard let message = viewModel.message(at: indexPath) else {
            return
        }
        
        present(actionSheet(for: message), animated: true)
    }
    
    private func actionSheet(for message: SBDBaseMessage) -> UIAlertController {
        let alert = UIAlertController(title: "React to a message", message: message.message, preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Smile", style: .default) { [weak self] _ in
                self?.viewModel.addReaction(to: message)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Delete Reaction", style: .destructive) { [weak self] _ in
                self?.viewModel.deleteReaction(in: message)
            }
        )

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        return alert
    }
    
}
