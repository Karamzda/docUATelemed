//
// ChatLayout
// Cell.swift
//

import ChatLayout
import DifferenceKit
import Foundation
import UIKit

public enum Cell: Hashable {

    public enum BubbleType {
        case normal
        case tailed
    }

    case message(Message, bubbleType: BubbleType)

    case messageGroup(MessageGroup)

    case date(DateGroup)

    case deliveryStatus

    var alignment: ChatItemAlignment {
        switch self {
        case let .message(message, _):
            return message.type == .incoming ? .leading : .trailing
        case .deliveryStatus:
            return .trailing
        case let .messageGroup(group):
            return group.type == .incoming ? .leading : .trailing
        case .date:
            return .center
        }
    }

}

extension Cell: Differentiable {

    public var differenceIdentifier: Int {
        switch self {
        case let .message(message, _):
            return message.differenceIdentifier
        case .deliveryStatus:
            return hashValue
        case let .messageGroup(group):
            return group.differenceIdentifier
        case let .date(group):
            return group.differenceIdentifier
        }
    }

    public func isContentEqual(to source: Cell) -> Bool {
        return self == source
    }

}
