//
// ChatLayout
// Section.swift
//

import DifferenceKit
import Foundation

public struct Section: Hashable {

    var id: Int

    var title: String

    var cells: [Cell]

}

extension Section: DifferentiableSection {

    public var differenceIdentifier: Int {
        return id
    }

    public func isContentEqual(to source: Section) -> Bool {
        return id == source.id
    }

    public var elements: [Cell] {
        return cells
    }

    public init<C: Swift.Collection>(source: Section, elements: C) where C.Element == Cell {
        self.init(id: source.id, title: source.title, cells: Array(elements))
    }

}
