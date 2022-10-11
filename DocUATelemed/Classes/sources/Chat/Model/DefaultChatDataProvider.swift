//
// ChatLayout
// DefaultRandomDataProvider.swift
//

import Foundation
import UIKit
import Quickblox

public protocol DefaultChatDataProviderDelegate: AnyObject {
    
    func sent(messageId: String)
    
    func delivered(messageId: String)
    
    func failed(messageId: String)
    
    func read(messageId: String)

    func received(messages: [RawMessage])
}

public protocol DefaultChatDataProvider {

    func loadInitialMessages(completion: @escaping ([RawMessage]) -> Void)

    func loadPreviousMessages(completion: @escaping ([RawMessage]) -> Void)

    func stop()
    
    func sendMessage(_ message: RawMessage, completion: @escaping (Swift.Result<RawMessage, Error>) -> Void)
    func sendMessage(_ message: QBChatMessage, completion: @escaping (Swift.Result<RawMessage, Error>) -> Void)
    func markAsRead(_ messageId: String)
}
