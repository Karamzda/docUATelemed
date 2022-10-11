//
// ChatLayout
// ImageLoader.swift
//

import Foundation
import UIKit

public protocol ImageLoader {

    func loadImage(from url: URL, completion: @escaping (Swift.Result<UIImage, Error>) -> Void)

}
