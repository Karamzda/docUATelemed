//
//  FileViewController.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 09.10.2022.
//

import Foundation
final class FileViewController {
    let url: URL
    let text: String

    weak var delegate: ReloadDelegate?
    
    weak var view: FileView? {
        didSet {
            view?.reloadData()
        }
    }

    let type: MessageType

    private let bubbleController: BubbleController

    init(url: URL, text: String , type: MessageType, bubbleController: BubbleController) {
        self.url = url
        self.text = text
        self.type = type
        self.bubbleController = bubbleController
    }
    
    func open(){
        delegate?.saveFile(url: url, name: text)
    }

}
