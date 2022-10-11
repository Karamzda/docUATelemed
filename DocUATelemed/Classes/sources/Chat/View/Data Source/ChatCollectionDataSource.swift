//
// ChatLayout
// ChatCollectionDataSource.swift
//

import ChatLayout
import Foundation
import UIKit

public protocol ChatCollectionDataSource: UICollectionViewDataSource, ChatLayoutDelegate {

    var sections: [Section] { get set }

    func prepare(with collectionView: UICollectionView)

}
