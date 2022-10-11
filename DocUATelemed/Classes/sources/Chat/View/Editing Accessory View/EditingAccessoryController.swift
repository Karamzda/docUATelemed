//
// ChatLayout
// EditingAccessoryController.swift
//

import Foundation
import UIKit

public protocol EditingAccessoryControllerDelegate: AnyObject {

    func deleteMessage(with id: String)

}

final class EditingAccessoryController {

    weak var delegate: EditingAccessoryControllerDelegate?

    weak var view: EditingAccessoryView?

    private let messageId: String

    init(messageId: String) {
        self.messageId = messageId
    }

    func deleteButtonTapped() {
        delegate?.deleteMessage(with: messageId)
    }

}
