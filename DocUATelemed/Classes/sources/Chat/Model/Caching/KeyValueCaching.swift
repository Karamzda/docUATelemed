//
// ChatLayout
// KeyValueCaching.swift
//

import Foundation

public protocol KeyValueCaching {

    associatedtype CachingKey

    associatedtype Entity

    func isEntityCached(for key: CachingKey) -> Bool

    func getEntity(for key: CachingKey) throws -> Entity

    func store(entity: Entity, for key: CachingKey) throws

}
