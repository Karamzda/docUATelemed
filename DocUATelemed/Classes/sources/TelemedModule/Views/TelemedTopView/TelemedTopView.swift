//
//  TelemedTopView.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 04.10.2022.
//

import UIKit


protocol TelemedTopViewProtocol: AnyObject {
    func setTimeLeft(value: String, color: UIColor)
}

public class TelemedTopView: UIView, TelemedTopViewProtocol {
    
    private var controller: TelemedTopViewControllerProtocol!
    private var configuration: TelemedTopViewConfiguration?
    
    private lazy var finishConsultationButton: UIButton = {
        let button = UIButton()
        button.setTitle("button.finish_consultation".localized, for: .normal)
        button.setImage(configuration?.closeImage, for: .normal)
        button.setTitleColor(configuration?.mainClor, for: .normal)
        button.titleLabel?.font = CustomFonts.Style.suisseIntlRegular.font(size: 18)
        return button
    }()
    
    private lazy var audioVideoCallStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var videoCallButton: UIButton = {
        let button = UIButton()
        button.setImage(configuration?.videoCallImage, for: .normal)
        return button
    }()
    
    private lazy var audioCallButton: UIButton = {
        let button = UIButton()
        button.setImage(configuration?.audioCallImage, for: .normal)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = TelemedColors.darkGrey.uiColor
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var greenRoundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = TelemedColors.darkGrey.uiColor
        return label
    }()
    
    public init(configuration: TelemedTopViewConfiguration) {
        super.init(frame: CGRect.zero)
        self.configuration = configuration
        controller = TelemedTopViewController(view: self)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(finishConsultationButton)
        addSubview(audioVideoCallStackView)
        audioVideoCallStackView.addArrangedSubview(videoCallButton)
        audioVideoCallStackView.addArrangedSubview(audioCallButton)
        addSubview(nameLabel)
        addSubview(greenRoundView)
        addSubview(timerLabel)
        setupAnchors()
        setupBindings()
    }
    
    private func setupAnchors() {
        finishConsultationButton
            .anchorTop(topAnchor, 16)
            .anchorLeft(leftAnchor, 16)
            .anchorHeight(24)
        
        audioVideoCallStackView
            .anchorCenterYToView(finishConsultationButton)
            .anchorRight(rightAnchor, 16)
            .anchorHeight(32)
        
        videoCallButton
            .anchorHeight(32)
            .anchorWidth(32)
        
        audioCallButton
            .anchorHeight(32)
            .anchorWidth(32)
        
        nameLabel
            .anchorLeft(leftAnchor, 16)
            .anchorRight(greenRoundView.leftAnchor, 16, relation: .greaterThanOrEqual)
            .anchorBottom(bottomAnchor, 12)
        
        timerLabel
            .anchorRight(rightAnchor, 16)
            .anchorBottom(bottomAnchor, 12)
            .anchorLeft(greenRoundView.rightAnchor, 5)
        
        greenRoundView
            .anchorHeight(5)
            .anchorWidth(5)
            .anchorCenterYToView(timerLabel)
        
        timerLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        timerLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
    }
    
    public func set(model: TelemedTopViewData) {
        controller.set(data: model)
        nameLabel.text = model.userName
    }
    
    private func setupBindings() {
        finishConsultationButton.addTarget(self, action: #selector(finishConsultationTapped), for: .touchUpInside)
        audioCallButton.addTarget(self, action: #selector(audioButtonTapped), for: .touchUpInside)
        videoCallButton.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
    }
    
    @objc private func finishConsultationTapped() {
        controller.finishCosultationTapped()
    }
    
    @objc private func audioButtonTapped() {
        controller.callButtonTapped()
    }
    
    @objc private func videoButtonTapped() {
        controller.videoButtonTapped()
    }
    
    func setTimeLeft(value: String, color: UIColor) {
        let timeLeftString = "label.time_left".localized + " " + value
        timerLabel.textColor = color
        timerLabel.text = timeLeftString
    }
}

