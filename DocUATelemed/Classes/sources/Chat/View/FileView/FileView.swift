//
//  FileView.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 09.10.2022.
//

import ChatLayout
import Foundation
import UIKit

final class FileView: UIView, ContainerCollectionViewCellDelegate {

    private lazy var stackView = UIStackView(frame: bounds)

    private lazy var imageView = UIImageView(image: ImagesHelper.loadImage(name: "ic_notes_blue"))
    
    private var controller: FileViewController?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFonts.Style.suisseIntlRegular.font(size: 15)
        return label
    }()
    
    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFonts.Style.suisseIntlRegular.font(size: 15)
        label.textColor = TelemedColors.darkGrey.uiColor
        return label
    }()

    private var viewPortWidth: CGFloat = 300

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    func prepareForReuse() {
        imageView.image = nil
    }

    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }


    func setup(with url: URL, name: String, size: Double) {
        titleLabel.text = name
        sizeLabel.text = "\(Int(size/1024))KB"
    }
    
    func setup(with controller: FileViewController) {
        self.controller = controller
    }

    func reloadData() {
        UIView.performWithoutAnimation {

        }
    }
    @objc func openAction() {
        controller?.open()
        
    }
    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(sizeLabel)
 
        
        imageView
            .anchorTop(topAnchor, 16)
            .anchorCenterXSuperview()
            .anchorHeight(88)
            .anchorWidth(88)
        
        titleLabel
            .anchorLeft(leftAnchor, 8)
            .anchorTop(imageView.bottomAnchor, 16)
            .anchorRight(rightAnchor, 8)
        
        sizeLabel
            .anchorLeft(leftAnchor, 8)
            .anchorTop(titleLabel.bottomAnchor, 4)
            .anchorBottom(bottomAnchor, 16)
        
        anchorWidth(240)
        
    }
    
    private func setupBindings() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAction))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    private func setupSize() {
        UIView.performWithoutAnimation {
            anchorWidth(240)
        }
    }
    


}
