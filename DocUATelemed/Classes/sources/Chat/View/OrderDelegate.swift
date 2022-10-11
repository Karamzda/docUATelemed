//
//  OrderDelegate.swift
//  DocUAChat
//
//  Created by Oleksandr Hudz on 15.09.2021.
//

import Foundation
public protocol OrderDelegate: AnyObject {
    func finishOrder(order: Int)
    
}
