//
// ChatLayout
// ImageMessageSource.swift
//

import Foundation
import UIKit

public enum ImageMessageSource: Hashable {
    case image(UIImage)
    case imageURL(URL)
}
