//
// ChatLayout
// ImageController.swift
//

import Foundation
import UIKit

final class ImageController {

    weak var view: ChatImageView? {
        didSet {
            view?.reloadData()
        }
    }

    weak var delegate: ReloadDelegate?

    var state: ImageViewState {
        guard let image = image else {
            return .loading
        }
        return .image(image)
    }

    private var image: UIImage?

    private let messageId: String

    private let source: ImageMessageSource

    private let bubbleController: BubbleController
    

    init(source: ImageMessageSource, messageId: String, bubbleController: BubbleController) {
        self.source = source
        self.messageId = messageId
        self.bubbleController = bubbleController
        loadImage()
    }
    
    func open(){
        switch source {
        case let .imageURL(url):
            self.delegate?.openAttach(url: url,id: messageId )
            break
        case .image(_):
            break
        }
    }

    private func loadImage() {
        switch source {
        case let .imageURL(url):
            if let image = try? imageCache.getEntity(for: .init(url: url)) {
                self.image = image
                view?.reloadData()
            } else {
                loader.loadImage(from: url) { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.delegate?.reloadMessage(with: self.messageId)
                }
            }
        case let .image(image):
            self.image = image
            view?.reloadData()
        }
    }

}
