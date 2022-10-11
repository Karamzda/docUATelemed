//
// ChatLayout
// CacheError.swift
//

import Foundation

public enum CacheError: Error {

    case notFound

    case invalidData

    case custom(Error)

}
