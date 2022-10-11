//
//  TelemedTopViewConfiguration.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 05.10.2022.
//

import Foundation

public struct TelemedTopViewConfiguration {
    public init(type: TelemedConfigurationType) {
        self.type = type
    }
    
    let type: TelemedConfigurationType
    
    private let imageHelper = ImagesHelper.self
    var audioCallImage: UIImage? {
        switch type {
        case .doctor:
            return imageHelper.loadImage(name: "doc_ic_audioCallIcon")
        case .patient:
            return imageHelper.loadImage(name: "pat_ic_audioCallIcon")
        }
    }
    
    var videoCallImage: UIImage? {
        switch type {
        case .doctor:
            return imageHelper.loadImage(name: "doc_ic_videoCallIcon")
        case .patient:
            return imageHelper.loadImage(name: "pat_ic_videoCallIcon")
        }
    }
    
    var closeImage: UIImage? {
        switch type {
        case .doctor:
            return imageHelper.loadImage(name: "doc_ic_close")
        case .patient:
            return imageHelper.loadImage(name: "pat_ic_close")
        }
    }
    
    
    var mainClor: UIColor {
        switch type {
        case .doctor:
            return TelemedColors.greenyBlue.uiColor
        case .patient:
            return TelemedColors.main.uiColor
        }
    }
}
