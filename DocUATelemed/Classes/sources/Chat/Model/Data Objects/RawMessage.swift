//
// ChatLayout
// RawMessage.swift
//

import Foundation
import UIKit

public struct RawMessage: Hashable {
    var id: String
    var date: Date
    var data: Data
    var userId: Int
    var status: MessageStatus = .sent
   
    // MARK: - Nested types
    enum Data: Hashable {
        case text(String)
        case url(URL)
        case image(ImageMessageSource)
        case file(url: URL, name: String, size: Double)
    }
}
