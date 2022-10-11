//
//  TelemedChatUser.swift
//  DocUAChat
//
//  Created by severehed on 06.05.2021.
//

import Foundation

public struct TelemedChatUser: Hashable {
    var id: Int?
    var firstName: String
    var lastName: String
    var middleName: String?
    var orderId: Int
    var isMe: Bool
    var avatarUrl: URL?
    
    public init(id: Int?,
                firstName: String, lastName: String, middleName: String?,
                orderId: Int, isMe: Bool, avatarUrl: URL?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.orderId = orderId
        self.isMe = isMe
        self.avatarUrl = avatarUrl
    }
    
    var shortName: String {
        var result = lastName.capitalized + " " + String(firstName.capitalized.first!) + "."
        if let middle = middleName, !middle.isEmpty {
            result += " \(middle.capitalized.first!)."
        }
        return result
    }
    
    var fullName: String {
        let components: [String?] = [
            lastName.capitalized,
            firstName.capitalized,
            middleName?.capitalized
        ]
        
        return components.compactMap({ $0 }).joined(separator: " ")
    }
}
