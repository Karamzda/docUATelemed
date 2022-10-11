//
//  DefaultInputAccessoryView.swift
//  DocUAChat
//
//  Created by severehed on 30.03.2021.
//

import UIKit
import InputBarAccessoryView
//import DocUASharedUI

open class DefaultInputAccessoryView: InputBarAccessoryView {
    open var attachButton: InputBarButtonItem = {
        let button = InputBarButtonItem().configure({
            $0.setSize(CGSize(width: 52, height: 36), animated: false)
        })
        return button
    }()
    
    open override func setup() {
        super.setup()
        separatorLine.backgroundColor = .clear
        let shadowView = self
        shadowView.layer.shadowColor = TelemedColors.dropShadown.uiColor.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = 16
        setLeftStackViewWidthConstant(to: 52, animated: true)
        setStackViewItems([attachButton], forStack: .left, animated: true)
    }
}
