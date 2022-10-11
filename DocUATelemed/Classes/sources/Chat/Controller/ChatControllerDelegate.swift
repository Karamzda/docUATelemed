//
// ChatLayout
// ChatControllerDelegate.swift
//

import Foundation

public protocol ChatControllerDelegate: AnyObject {

    func update(with sections: [Section])

}
