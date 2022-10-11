//
// ChatLayout
// AsyncKeyValueCaching.swift
//

import Foundation

public protocol AsyncKeyValueCaching: KeyValueCaching {

    associatedtype CachingKey

    associatedtype Entity

    func getEntity(for key: CachingKey, completion: @escaping (Swift.Result<Entity, Error>) -> Void)

}

public extension AsyncKeyValueCaching {

    func getEntity(for key: CachingKey, completion: @escaping (Swift.Result<Entity, Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                let entity = try self.getEntity(for: key)
                DispatchQueue.main.async {
                    completion(.success(entity))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

}
