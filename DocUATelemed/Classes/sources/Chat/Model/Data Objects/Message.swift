//
// ChatLayout
// Message.swift
//

import ChatLayout
import DifferenceKit
import Foundation

enum MessageType: Hashable {
    case incoming
    case outgoing
    var isIncoming: Bool {
        return self == .incoming
    }
}

enum MessageStatus: Hashable {
    case sending
    case sent
    case failed
    case received
    case read
}

extension ChatItemAlignment {
    var isIncoming: Bool {
        return self == .leading
    }
}

public struct DateGroup: Hashable {
    var id: String
    var date: Date
    var value: String {
        return ChatDateFormatter.shared.string(from: date)
    }

    init(id: String, date: Date) {
        self.id = id
        self.date = date
    }

}

extension DateGroup: Differentiable {

    public var differenceIdentifier: Int {
        return hashValue
    }

    public func isContentEqual(to source: DateGroup) -> Bool {
        self == source
    }

}

public struct MessageGroup: Hashable {

    var id: String
    var title: String
    var type: MessageType
    var status: MessageStatus

    init(id: String, title: String, type: MessageType, status: MessageStatus) {
        self.id = id
        self.title = title
        self.type = type
        self.status = status
    }

}

extension MessageGroup: Differentiable {

    public var differenceIdentifier: Int {
        return hashValue
    }

    public func isContentEqual(to source: MessageGroup) -> Bool {
        self == source
    }

}

public struct Message: Hashable {
    
    var id: String
    var date: Date
    var data: Data
    var owner: TelemedChatUser
    var type: MessageType
    var status: MessageStatus = .sent
    
    public enum Data: Hashable {
        case text(String)
        case url(URL, isLocallyStored: Bool)
        case image(ImageMessageSource, isLocallyStored: Bool)
        case file(url: URL, name: String, size: Double)
    }

}

extension Message: Differentiable {

    public var differenceIdentifier: Int {
        return id.hashValue
    }

    public func isContentEqual(to source: Message) -> Bool {
        return self == source
    }

}
