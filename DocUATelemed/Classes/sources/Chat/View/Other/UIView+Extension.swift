//
// ChatLayout
// UIView+Extension.swift
//

import Foundation
import UIKit

extension UIView {

    // Even though we do not set it animated - it can happen during the animated batch update
    // http://www.openradar.me/25087688
    // https://github.com/nkukushkin/StackView-Hiding-With-Animation-Bug-Example
    var isHiddenSafe: Bool {
        get {
            return isHidden
        }
        set {
            guard isHidden != newValue else {
                return
            }
            isHidden = newValue
        }
    }

}
