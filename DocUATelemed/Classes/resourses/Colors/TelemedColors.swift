//
//  TelemedColors.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 04.10.2022.
//

import UIKit

enum TelemedColors {
    case main
    case greenyBlue
    case darkGrey
    case athensGray
    case dropShadown
    case backgroundGrey
}

extension TelemedColors {
    var uiColor: UIColor {
        switch self {
        case .main:
            return UIColor(red: 0.040, green: 0.340, blue: 0.760, alpha: 1.0)
        case .darkGrey:
            return UIColor(red: 0.450, green: 0.460, blue: 0.470, alpha: 1.0)
        case .greenyBlue:
            return UIColor(red: 62.0 / 255.0, green: 191.0 / 255.0, blue: 172.0 / 255.0, alpha: 1.0)
        case .athensGray:
            return UIColor(red: 0.971, green: 0.977, blue: 0.983, alpha: 1)
        case .dropShadown:
            return UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.12)
        case .backgroundGrey:
            return UIColor(white: 0.93, alpha: 1)
        }
    }
}
