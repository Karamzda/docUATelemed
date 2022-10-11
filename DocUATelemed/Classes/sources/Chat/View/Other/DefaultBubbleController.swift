//
// ChatLayout
// DefaultBubbleController.swift
//

import ChatLayout
import Foundation
import UIKit
//import DocUASharedUI

final class DefaultBubbleController<CustomView: UIView>: BubbleController {
    private let backgroundTag = 101
    private let ownerLabelTag = 102
    private let dateLabelTag = 103

    private let type: MessageType
    private let bubbleType: Cell.BubbleType
    private let user: TelemedChatUser
    private let date: Date

    weak var bubbleView: ImageMaskedView<CustomView>? {
        didSet {
            setupBubbleView()
        }
    }

    init(bubbleView: ImageMaskedView<CustomView>, type: MessageType, bubbleType: Cell.BubbleType, user: TelemedChatUser, date: Date) {
        self.type = type
        self.bubbleType = bubbleType
        self.bubbleView = bubbleView
        self.user = user
        self.date = date
        setupBubbleView()
    }

    private func setupBubbleView() {
        guard let bubbleView = bubbleView else {
            return
        }
        
        let titleHeight: CGFloat = 16
        
        let marginOffset: CGFloat = type.isIncoming ? -ChatConstants.tailSize : ChatConstants.tailSize
        let edgeInsets = UIEdgeInsets(top: 14 + titleHeight + 4, left: 16 - marginOffset, bottom: 14, right: 16 + marginOffset)
        bubbleView.layoutMargins = edgeInsets
//        bubbleView.backgroundColor = .clear//type.isIncoming ? UIColor.white : (Appearence == .patient ? UIColor(hexString: "#0957C3") : UIColor(hexString: "#ECF9F7"))
        bubbleView.customView.layoutMargins = .zero
        
        bubbleView.maskTransformation = type.isIncoming ? .flippedVertically : .asIs
        
        if bubbleView.viewWithTag(backgroundTag) == nil {
            let background = UIView()
            background.tag = backgroundTag
            background.translatesAutoresizingMaskIntoConstraints = false
            bubbleView.insertSubview(background, at: 0)
            let top = background.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: titleHeight + 4)
            top.priority = .defaultLow
            top.isActive = true
            background.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
            background.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
            background.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
            background.layer.cornerRadius = 24
            background.layer.shadowColor = TelemedColors.dropShadown.uiColor.cgColor
            background.layer.shadowOpacity = 1
            background.layer.shadowRadius = 8
            background.layer.shadowOffset = CGSize(width: 0, height: 2)
            
            
            let ownerLabel = UILabel()
            ownerLabel.tag = ownerLabelTag
            ownerLabel.translatesAutoresizingMaskIntoConstraints = false
            ownerLabel.font = CustomFonts.Style.suisseIntlMedium.font(size: 12)
            ownerLabel.textColor = UIColor(hexString: "#7B848D")
            bubbleView.addSubview(ownerLabel)
            
            let ownerTop = ownerLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor)
            ownerTop.priority = .defaultLow
            ownerTop.isActive = true
            ownerLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1), for: .horizontal)
            ownerLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14).isActive = true
            ownerLabel.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
            
            let dateLabel = UILabel()
            dateLabel.tag = dateLabelTag
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.font = CustomFonts.Style.suisseIntlMedium.font(size: 12)
            dateLabel.textColor = UIColor(hexString: "#7B848D")
            bubbleView.addSubview(dateLabel)
            
            let dateLabelTop = dateLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor)
            dateLabelTop.priority = .defaultLow
            dateLabelTop.isActive = true
            dateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14).isActive = true
            dateLabel.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: ownerLabel.trailingAnchor, constant: 4).isActive = true
        }
        
        let background = bubbleView.viewWithTag(backgroundTag)!
        background.backgroundColor = type.isIncoming ? UIColor.white : (Appearence == .patient ? UIColor(hexString: "#0957C3") : UIColor(hexString: "#ECF9F7"))
        
        background.layer.maskedCorners = type.isIncoming ?
            [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        let ownerLabel = bubbleView.viewWithTag(ownerLabelTag) as! UILabel
        ownerLabel.text = type.isIncoming ? user.firstName : "telemed_chat_you".localized
        
        let dateLabel = bubbleView.viewWithTag(dateLabelTag) as! UILabel
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: date)
    }
}
