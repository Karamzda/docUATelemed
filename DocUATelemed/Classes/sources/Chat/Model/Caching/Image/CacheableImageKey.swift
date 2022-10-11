//
// ChatLayout
// CacheableImageKey.swift
//

import Foundation
import UIKit

public struct CacheableImageKey: Hashable, PersistentlyCacheable {

    public let url: URL

    var persistentIdentifier: String {
        return (url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? url.absoluteString)
    }

}
