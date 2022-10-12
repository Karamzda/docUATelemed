//
//  TelemedCallController.swift
//  DocUA
//
//  Created by severehed on 30.03.2021.
//

import UIKit
import SnapKit
import Quickblox
import Kingfisher

public class TelemedCallController: UIViewController {
    
    let abonent: TelemedChatUser?
    weak var caller: TelemedMainViewController?
    let label = UILabel()
    
    init(state: State,
         abonent: TelemedChatUser?,
         caller: TelemedMainViewController) {
        self.state = state
        self.abonent = abonent
        self.caller = caller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum State {
        case outcomingVideo
        case outcomingAudio
        case incomingAudio
        case incomingVideo
        case activeAudio
        case activeVideo
        case backgroundAudio
        case backgroundVideo
    }
    
    var state: State {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    
    var session: QBRTCSession? {
        didSet {
            if isViewLoaded {
//                updateUI()
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avataImg: UIImageView!
    
    var mainStackView: UIStackView!
    var incomingStackView: UIStackView!
    var remoteVideoView: QBRTCRemoteVideoView!
    var localVideoView: UIView!
    
    var videoCapture: QBRTCCameraCapture?
    
    var muteButton: UIButton!
    var speakerButton: UIButton!
    var disableCameraButton: UIButton!
    var switchCameraButton: UIButton!
    var backToChatButton: UIButton!
    
    var speaker: Bool = false
    
    public override func loadView() {
        super.loadView()
        loadSubviews()
        QBRTCClient.instance().add(self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        updateControlsUI()
        updateVideoUI()
    }
    
    func setSpeakerAsDefault() {
        speaker = true
        let audioSession = QBRTCAudioSession.instance()
        audioSession.overrideOutputAudioPort(speaker ? .speaker : .none)
    }
    
    func incomingSession(_ session: QBRTCSession) {
        guard self.session == nil else { return }
        self.session = session
        state = session.conferenceType == .audio ? .incomingAudio : .incomingVideo
        setSpeakerAsDefault()
        
        
    }
    
    func acceptedCall(_ session: QBRTCSession) {
        guard self.session == session else { return }
        state = session.conferenceType == .audio ? .activeAudio : .activeVideo
        setSpeakerAsDefault()
    }
    
    func audioCall() {
        guard session == nil else { return }
        guard let occupants = TelemedChatManager.shared.dialog?.occupantIDs else { return }
        state = .outcomingAudio
        let session = QBRTCClient.instance().createNewSession(withOpponents: occupants, with: .audio)
        self.session = session
        session.startCall(nil)
        setSpeakerAsDefault()
    }
    
    func videoCall() {
        guard session == nil else { return }
        guard let occupants = TelemedChatManager.shared.dialog?.occupantIDs else { return }
        state = .outcomingVideo
      
        let session = QBRTCClient.instance().createNewSession(withOpponents: occupants.filter({ Int(truncating: $0) == abonent?.id }), with: .video)
        self.session = session
        session.startCall(nil)
        setSpeakerAsDefault()
    }
    
    @objc func acceptCallAction(_ sender: UIButton) {
        guard let session = session else { return }
        session.acceptCall(nil)
        state = session.conferenceType == .audio ? .activeAudio : .activeVideo
        setSpeakerAsDefault()
    }
    
    @objc func rejectCallAction(_ sender: UIButton) {
        let session = self.session
        self.session = nil
        session?.rejectCall(nil)
    }
    
    @objc func muteAction(_ sender: UIButton) {
        guard let session = session else { return }
        session.localMediaStream.audioTrack.isEnabled = !session.localMediaStream.audioTrack.isEnabled
        updateControlsUI()
    }
    
    @objc func speakerAction(_ sender: UIButton) {
        guard let _ = session else { return }
        speaker = !speaker
        let audioSession = QBRTCAudioSession.instance()
        audioSession.overrideOutputAudioPort(speaker ? .speaker : .none)
    }
    
    @objc func switchCameraAction(_ sender: UIButton) {
        guard let videoCapture = self.videoCapture else { return }
        let position = videoCapture.position
        let newPosition: AVCaptureDevice.Position = position == .front ? .back : .front
        if videoCapture.hasCamera(for: newPosition) {
            videoCapture.position = newPosition
        }
    }
    
    @objc func disableCameraAction(_ sender: UIButton) {
        guard let session = session else { return }
        session.localMediaStream.videoTrack.isEnabled = !session.localMediaStream.videoTrack.isEnabled
        updateUI()
    }
    
    @objc func endCallAction(_ sender: UIButton) {
       endCallAction()
    }
    
    public func endCallAction() {
        let session = self.session
        self.session = nil
        session?.hangUp(nil)
    }
    
    
    private func updateControlsUI() {
        let connectionTypeTitle = state == .incomingAudio ? "doctor_want_to_connect_with_audio".localized : "doctor_want_to_connect_with_video".localized
        label.text = "doctor_title".localized + " " + (abonent?.fullName ?? "") + "\n" + connectionTypeTitle
        
        switch state {
        case .incomingAudio, .incomingVideo:
            mainStackView.isHidden = true
            incomingStackView.isHidden = false
        default:
            mainStackView.isHidden = false
            incomingStackView.isHidden = true
        }
        
        switch state {
        case .outcomingVideo, .activeVideo, .incomingVideo:
            mainStackView.arrangedSubviews.forEach({
                if let button = $0 as? UIButton {
                    button.setTitleColor(.white, for: .normal)
                }
            })
        default:
            mainStackView.arrangedSubviews.forEach({
                if let button = $0 as? UIButton {
                    button.setTitleColor(.black, for: .normal)
                }
            })
        }
        
        self.speakerButton.isHidden = state != .activeAudio
        self.disableCameraButton.isHidden = state != .activeVideo
        self.switchCameraButton.isHidden = state != .activeVideo
        
        let muted = session?.localMediaStream.audioTrack.isEnabled != true
        
        self.muteButton.setImage(ImagesHelper.loadImage(name: muted ? "ic_mic_mute" : "ic_mic"), for: .normal)
        self.muteButton.setTitle(!muted ? "telemed_turn_off_mic".localized : "telemed_turn_on_mic".localized, for: .normal)
        
        let cameraDisabled = session?.localMediaStream.videoTrack.isEnabled != true
        self.disableCameraButton.setImage(ImagesHelper.loadImage(name: cameraDisabled ? "ic_camera_mute" : "ic_camera"), for: .normal)
        self.disableCameraButton.setTitle(cameraDisabled ? "telemed_turn_on_camera".localized : "telemed_turn_off_camera".localized, for: .normal)
    }
    
    private func updateVideoUI() {
        if state == .outcomingVideo || state == .activeVideo {
            if videoCapture == nil {
                let videoFormat = QBRTCVideoFormat()
                videoFormat.frameRate = 30
                videoFormat.pixelFormat = .format420f
                videoFormat.width = 640
                videoFormat.height = 480
                
                self.videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
                
                self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
                
                self.videoCapture?.previewLayer.frame = self.localVideoView.bounds
                self.videoCapture?.startSession()
                
                self.localVideoView.layer.insertSublayer(self.videoCapture!.previewLayer, at: 0)
            }else{
                self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
                self.videoCapture?.startSession()
                
            }
            localVideoView.isHidden = session?.localMediaStream.videoTrack.isEnabled != true
            remoteVideoView.isHidden = state == .outcomingVideo
        }
        else {
            localVideoView.isHidden = true
            remoteVideoView.isHidden = true
            if let videoCapture = self.videoCapture {
                videoCapture.previewLayer.removeFromSuperlayer()
                videoCapture.stopSession(nil)
                self.videoCapture = nil
            }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.videoCapture?.previewLayer.frame = self.localVideoView.bounds
    }
    
    deinit {
        QBRTCClient.instance().remove(self)
    }
}

extension TelemedCallController: QBRTCClientDelegate {
    public func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        remoteVideoView.setVideoTrack(videoTrack)
        remoteVideoView.isEnabled = true
    }
}

private extension TelemedCallController {

    func loadSubviews() {
        view.backgroundColor = TelemedColors.backgroundGrey.uiColor
        
        let imageView = UIImageView(image: ImagesHelper.loadImage(name: "img_audio_avatar"))
        imageView.kf.setImage(with: abonent?.avatarUrl,
                              placeholder: ImagesHelper.loadImage(name: "doctor_avatar_circular_frame"))
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview().offset(96)
            maker.width.equalTo(160)
            maker.height.equalTo(160)
        }
        
        let avatar = UIImageView()
        avatar.layer.cornerRadius = 44
        avatar.layer.masksToBounds = true
        view.addSubview(avatar)
        avatar.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(imageView)
            maker.centerY.equalTo(imageView)
            maker.width.equalTo(88)
            maker.height.equalTo(88)
        }
        
   
        
        
        label.numberOfLines = 0
        label.textAlignment = .center
//        if TelemedChatManager.appearance == .doctor {
//            label.text = TelemedChatManager.shared.sender.fullName
//        } else {
//            label.text = TelemedChatManager.shared.sender.fullName
//        }
        let connectionTypeTitle = state == .incomingAudio ? "doctor_want_to_connect_with_audio".localized : "doctor_want_to_connect_with_video".localized
        
        label.text = "doctor_title".localized + " " + (abonent?.fullName ?? "") + "\n" + connectionTypeTitle
        label.font = CustomFonts.Style.suisseIntlBold.font(size: 15)
        view.addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(24)
            maker.trailing.equalToSuperview().offset(-24)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(imageView.snp.bottom).offset(44)
        }
        
        
        let remoteVideoView = QBRTCRemoteVideoView()
        remoteVideoView.backgroundColor = .clear
        remoteVideoView.contentMode = .scaleAspectFit
//        remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        view.addSubview(remoteVideoView)
        remoteVideoView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        let localVideoView = UIView()
        localVideoView.contentMode = .scaleAspectFill
        localVideoView.layer.cornerRadius = 20
        localVideoView.layer.masksToBounds = true
        view.addSubview(localVideoView)
        localVideoView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(56)
            maker.left.equalToSuperview().offset(16)
            maker.width.equalTo(85)
            maker.height.equalTo(118)
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(24)
            maker.trailing.equalToSuperview().offset(-24)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
        
        let buttonsData: [(String, String, Selector)] = [
            ("telemed_turn_off_mic".localized, "ic_mic_mute", #selector(muteAction(_:))),
            ("telemed_speaker".localized, "ic_audiospeaker", #selector(speakerAction(_:))),
            ("telemed_turn_off_camera".localized, "ic_camera_mute", #selector(disableCameraAction(_:))),
            ("telemed_change_camera".localized, "ic_change_camera", #selector(switchCameraAction(_:))),
            ("telemed_stop_audio".localized, "ic_end_call", #selector(endCallAction(_:)))
        ]
        
        buttonsData.forEach({
            let button = UIButton()
            button.setTitle($0.0, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = CustomFonts.Style.suisseIntlMedium.font(size: 12)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            
            button.setImage(ImagesHelper.loadImage(name: $0.1), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: -39, left: 14, bottom: 0, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 48, left: -44, bottom: 0, right: 0)
            stackView.addArrangedSubview(button)
            button.snp.makeConstraints { (maker) in
                maker.width.equalTo(74)
                maker.height.equalTo(84)
            }
            button.addTarget(self, action: $0.2, for: .touchUpInside)
        })
        
        let incomingStackView = UIStackView()
        incomingStackView.axis = .horizontal
        incomingStackView.alignment = .center
        incomingStackView.distribution = .equalCentering
        incomingStackView.spacing = 80
        view.addSubview(incomingStackView)
        incomingStackView.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(56)
            maker.trailing.equalToSuperview().offset(-56)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-72)
        }
        
        let incomingData: [(String, String, Selector)] = [
            ("telemed_cancel".localized, "ic_reject_call", #selector(rejectCallAction(_:))),
            ("telemed_approve".localized, "ic_accept_сall", #selector(acceptCallAction(_:)))
        ]
        
        incomingData.forEach({
            let button = UIButton()
            button.setTitle($0.0, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = CustomFonts.Style.suisseIntlMedium.font(size: 12)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.setImage(ImagesHelper.loadImage(name: $0.1), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: -32, left: 16, bottom: 0, right: 16)
            button.titleEdgeInsets = UIEdgeInsets(top: 54, left: -54, bottom: 0, right: 0)
            button.contentHorizontalAlignment = .center
            button.imageView?.contentMode = .scaleAspectFit
            incomingStackView.addArrangedSubview(button)
            button.snp.makeConstraints { (maker) in
                maker.width.equalTo(88)
                maker.height.equalTo(88)
            }
            button.addTarget(self, action: $0.2, for: .touchUpInside)
        })
        
        //TODO: Add function for change state
        backToChatButton = UIButton()
        
        backToChatButton.setTitle("telemed_back_to_chat".localized, for: .normal)
        backToChatButton.titleLabel?.font = CustomFonts.Style.suisseIntlMedium.font(size: 15)
        backToChatButton.setTitleColor(.white, for: .normal)
        backToChatButton.backgroundColor = UIColor(hexString: "#00CC4C")
        backToChatButton.addTarget(self,
                                   action: #selector(backToChatAction),
                                   for: .touchUpInside)
        view.addSubview(backToChatButton)
       
        backToChatButton.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.height.equalTo(40)
        }
        
        self.mainStackView = stackView
        self.incomingStackView = incomingStackView
        self.remoteVideoView = remoteVideoView
        self.localVideoView = localVideoView
        
        self.muteButton = stackView.arrangedSubviews[0] as? UIButton
        self.speakerButton = stackView.arrangedSubviews[1] as? UIButton
        self.disableCameraButton = stackView.arrangedSubviews[2] as? UIButton
        self.switchCameraButton = stackView.arrangedSubviews[3] as? UIButton
    }
    
    @objc func backToChatAction() {
        caller?.backToChatAction()
        
        
//        let title = session?.conferenceType == .audio ?
//            "Back to call" : "Back to video"
//        self.backToChatButton.setTitle(title, for: .normal)
//
//        state = session?.conferenceType == .audio ?
//            .backgroundAudio : .backgroundVideo
//
//        self.localVideoView.isHidden = true
//        self.remoteVideoView.isHidden = true
        
    }
    
}

