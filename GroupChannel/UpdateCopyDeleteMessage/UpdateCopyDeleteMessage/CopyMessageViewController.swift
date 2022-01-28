//
//  EditMessageViewController.swift
//  UpdateCopyDeleteMessage
//
//  Created by Ernest Hong on 2022/01/28.
//

import UIKit
import Common
import SendBirdSDK

final class EditMessageViewController: BaseGroupChannelViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let message = viewModel.messages[indexPath.row]
        
        present(actionSheet(for: message), animated: true)
    }
    
    private func actionSheet(for message: SBDBaseMessage) -> UIAlertController {
        let alert = UIAlertController(title: "Choose action for message", message: message.message, preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Update", style: .default) { _ in
                
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Copy", style: .default) { _ in
                UIPasteboard.general.string = message.message
            }
        )

        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                
            }
        )

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        return alert
    }

}

