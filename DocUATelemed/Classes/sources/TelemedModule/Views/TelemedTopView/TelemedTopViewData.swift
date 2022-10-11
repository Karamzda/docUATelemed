//
//  TelemedTopViewData.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 04.10.2022.
//

import Foundation

public struct TelemedTopViewData {

    let endDate: Date
    let userName: String
    public init(endDate: Date, userName: String) {
        self.endDate = endDate
        self.userName = userName
    }
}
