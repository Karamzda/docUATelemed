//
// ChatLayout
// ChatController.swift
//

import Foundation
import Quickblox

public protocol ChatController {
    func loadInitialMessages(completion: @escaping ([Section]) -> Void)
    func loadPreviousMessages(completion: @escaping ([Section]) -> Void)
    func sendMessage(_ data: Message.Data, completion: @escaping ([Section]) -> Void)
    func sendMessage(_ message: QBChatMessage, completion: @escaping ([Section]) -> Void)
    func willDisplay(_ cell: Cell)
}
