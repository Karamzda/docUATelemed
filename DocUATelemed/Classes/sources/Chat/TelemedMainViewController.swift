//
//  TelemedMainViewController.swift
//  DocUAPatient
//
//  Created by severehed on 15.03.2021.
//  Copyright © 2021. All rights reserved.
//

import UIKit
import Quickblox
import QuickLook
import Network
import QuickbloxWebRTC

open class TelemedMainViewController: UIViewController, PhotoAttaching {

    private var previewItem: URL!
    
    public enum State {
        case chat
        case calling
        case call
    }
    
    public var isChatShowing = true
    
    public private(set) var state: State = .chat {
        willSet {
            hideKeyboard()
        }
        didSet {
            self.becomeFirstResponder()
            reconnectionView.isHidden = true
            switch state {
            case .chat: switchToChat()
            case .call: switchToCall()
            case .calling: reconnectionView.isHidden = false
            }
            reloadInputViews()
            updateUI()
        }
    }
    
    public var recipient: TelemedChatUser!
    public var sender: TelemedChatUser!
    public var orderId: Int!
    private var endTimeInterval: TimeInterval!
    public var endDate:Date!

    
    @IBOutlet weak var reconnectionView: UIView!
    @IBOutlet weak var onlineStatusView: UIView!
    @IBOutlet private weak var HeaderView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet private weak var recipientNameLabel: UILabel!
    @IBOutlet private weak var timeLeftLabel: UILabel!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var waitingTimeLabel: UILabel!
    @IBOutlet weak var backToChatButton: UIButton!
    @IBOutlet weak var connectionErrorLabel: UILabel!
    
    var height: NSLayoutConstraint!
    
    private var timer: Timer?
    private var waitTimer: Timer?
    private var startDate = Date()
    private var waitStartDate = Date()
    private var image: UIImage!
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
        @IBOutlet public private(set) weak var chatContainer: UIView!
    
    public private(set) var chatViewController: ChatViewController?
    
    public private(set) lazy var callViewController: TelemedCallController = {
        
        let abonent = sender.isMe ? recipient : sender
        
        return TelemedCallController(state: .outcomingAudio,
                                     abonent: abonent, caller: self)
    }()
    
    public var inputBarView: DefaultInputAccessoryView? {
        return chatViewController?.inputBarView
    }
    
    open override var inputAccessoryView: UIView? {
        if state == .chat || state == .call {
            return chatViewController?.inputBarView
        }
        else {
            return nil
        }
    }
    
    open override var canResignFirstResponder: Bool {
        return true
    }
    
    open override var canBecomeFirstResponder: Bool {
        return state == .chat || state ==  .call
    }
    
    // MARK: - PhotoAttach
    var isPhotoAttached: Bool { return attachedImage != nil }
    lazy var imagePickerController: UIImagePickerController = self.createImagePickerController()
    
    private var attachedImage: UIImage?
    
    func removePhoto() {
        attachedImage = nil
    }
    
    func dismissAttachment(){
        self.inputBarView?.isHidden=false
    }
    
    public func endCall() {
        callViewController.endCallAction()
    }
    
    private func createImagePickerController() -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
    
    
    // MARK: - Init
    convenience init() {
        self.init(nibName: "TelemedMainViewController", bundle: Bundle(for: TelemedMainViewController.self))
        
    }
    
    
    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        CustomFonts.loadFonts()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fixTap))
        
        HeaderView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name:
                                                UIApplication.willResignActiveNotification, object: nil)
           
           NotificationCenter.default.addObserver(self, selector: #selector(onResume), name:
                                                    UIApplication.didBecomeActiveNotification, object: nil)
        backToChatButton.isHidden = true
        height = backToChatButton.heightAnchor.constraint(equalToConstant: 0)
                 height.isActive = true
        height.constant = 0
        recipientNameLabel.text = recipient.isMe ? sender.fullName : recipient.fullName
        recipientNameLabel.sizeToFit()
        timeLeftLabel.text = nil
        hideKeyboardWhenTappedAround()
        onlineStatusView.layer.cornerRadius = self.onlineStatusView.frame.width / 2
        reconnectionView.isHidden = false
        waitingView.isHidden = true
        startDialog()
        
        connectionErrorLabel.text = "telemed.connection.error".localized
        
        setFlugs(audio: audioCallButton, video: videoCallButton)
        
        monitor.pathUpdateHandler = { [weak self] path in
           if path.status == .satisfied {
              print("Connected")
            DispatchQueue.main.async { [weak self] in
                guard self != nil else {
                    return
                }
                self?.reconnectionView.isHidden=true
                self?.inputBarView?.isHidden=false
            }
           } else {
              print("Disconnected")
            DispatchQueue.main.async { [weak self] in
                guard self != nil else {
                    return
                }
                self?.stopWaitingTimer()
                self?.reconnectionView.isHidden=false
                self?.inputBarView?.isHidden=true
                self?.dismissKeyboard()
            }
           
           }
           print(path.isExpensive)
            
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        monitor.start(queue: queue)
        startTimer()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        monitor.cancel()
        stopTimer()
    }
    
    @objc private func fixTap() {
        
    }
    
    
    @objc func onPause() {
        stopTimer()
    }

    @objc func onResume() {
        startTimer()
    }
    
    open override func loadView() {
        super.loadView()
        if TelemedChatManager.appearance == .doctor {
            closeButton.setTitleColor(TelemedColors.greenyBlue.uiColor, for: .normal)
        } else {
            closeButton.setTitleColor(TelemedColors.main.uiColor, for: .normal)
        }
        closeButton.setTitle("telemed_close".localized, for: .normal)
        
        closeButton.setImage( ImagesHelper.loadImage(resolvedName: "ic_close"), for: .normal)
        videoCallButton.setImage(ImagesHelper.loadImage(resolvedName: "ic_videoCallIcon"), for: .normal)
        audioCallButton.setImage(ImagesHelper.loadImage(resolvedName: "ic_audioCallIcon"), for: .normal)
    }
    
    // MARK: - Internal Methods
    func postLoad() {
        QBRTCClient.instance().add(self)
    }
    
    func updateUI() {
        if callViewController.session == nil {
            setFlugs(audio: audioCallButton, video: videoCallButton)
            backToChatButton.isHidden = true
            height.constant = 0
        }
        else {
            audioCallButton.isHidden = true
            videoCallButton.isHidden = true
        }
    }
    
    func startTimer() {
        guard timer == nil else { return }
        startDate = Date()
  
        endTimeInterval = endDate.timeIntervalSinceNow - startDate.timeIntervalSinceNow
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.endTimeInterval -= 1
            if self.endTimeInterval < 0 {
                timer.invalidate()
                self.sessionExpiredAction(timer)
            } else {
                
                if self.endTimeInterval < (5 * 60) {
                    self.timeLeftLabel.textColor = .red
                }
                
                if((Int(self.endTimeInterval) % 60) % 4 == 0){
                    if(self.monitor.currentPath.status == .satisfied){
                        QBChat.instance.pingUser(withID: UInt(self.recipient.id ?? 0), timeout: 2.0) { (timeInterval, success) in
                            // time interval of ping and whether it was successful
                            if(!success){
                                self.stopTimer()
                                self.startWaitingTimer()
                            }
                        }
                        
                    }
                    
                }
                
                let components = DateComponents(minute: Int(self.endTimeInterval) / 60, second: Int(self.endTimeInterval) % 60)
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                self.timeLeftLabel.text = "telemed_chat_till_end".localized + " " + (formatter.string(from: components) ?? "")
            }
        })
    }
    
    func startWaitingTimer() {
        guard waitTimer == nil else { return }
        self.waitingTimeLabel.text = ""
        self.waitingView.isHidden = false
        hideKeyboard()
        inputBarView?.isHidden=true
        waitStartDate = Date()
        waitTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard let self = self else {
                timer.invalidate()
                return
            }
            let time = TelemedConstants.waitingDuration - (Date().timeIntervalSince1970 - self.waitStartDate.timeIntervalSince1970)
            if time < 0 {
                timer.invalidate()
                self.waitingExpiredAction(timer)
            } else {
                if((Int(time) % 60) % 4 == 0){
                QBChat.instance.pingUser(withID: UInt(self.recipient.id ?? 0), timeout: 2.0) { (timeInterval, success) in
                    // time interval of ping and whether it was successful
                    if(success){
                        self.stopWaitingTimer()
                        self.startTimer()
                    }
                    
                }}
                let components = DateComponents(minute: Int(time) / 60, second: Int(time) % 60)
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                self.waitingTimeLabel.text =  formatter.string(from: components) ?? ""
            }
        })
    }
    
    public func stopTimer() {
      timer?.invalidate()
      timer = nil
    }
    
    func stopWaitingTimer() {
        self.waitingView.isHidden = true
        
        if isChatShowing {
            inputBarView?.isHidden=false
            inputBarView?.inputTextView.becomeFirstResponder()
        }
        
        
      waitTimer?.invalidate()
      waitTimer = nil
    }
    
    func sessionExpiredAction(_ sender: Any) {
        finishAction(isNoOption: false)
    }
    
    func waitingExpiredAction(_ sender: Any) {
        cancelAction()
    }
    
    func attachAction(_ sender: UIButton) {
        hideKeyboard()
        inputBarView?.isHidden=true
        showPhotoAttachingOptions()
        LogUtils.info("attach action")
    }
    
    open func build(_ dialog: QBChatDialog, _ userId: UInt) -> ChatViewController {
        let dataProvider = QuickBloxDataProvider(dialog: dialog, receiverId: userId)
        let messageController = DefaultChatController(dataProvider: dataProvider, userId: Int(userId))
        messageController.openFile = { [weak self] (url, name) in
            
            FilesDownloader.downloadfile(filename:name,url:url,completion: {(success, fileLocationURL) in
                DispatchQueue.main.async {
                    if success {
                        let previewController = QLPreviewController()
                        previewController.dataSource = self
//                        previewController.modalPresentationStyle = .overFullScreen
                        self?.hideKeyboard()
                        previewController.delegate = self
                        self?.previewItem = fileLocationURL
                        self?.inputBarView?.isHidden=true
                        self?.present(previewController, animated: true, completion: {
                        })
                    }else{
                        print("error")
                      //  self?.showAlert(title: "telemed_error_upload_file".localized , subtitle: nil)
                    }
                }
            })
        }
//        messageController.openFile = { [weak self] (id, name) in
//            guard let self = self else { return }
//            QBRequest.downloadFile(withUID: id) { response, data in
//                print(data)
//            } statusBlock: { <#QBRequest#>, <#QBRequestStatus#> in
//                <#code#>
//            }
//
//            
//        }
        
        messageController.openAttachAction = { [weak self]  (result,id) in
            FilesDownloader.downloadfile(filename:"img_\(id).jpg",url:result,completion: {(success, fileLocationURL) in
                DispatchQueue.main.async {
                    if success {
                        let previewController = QLPreviewController()
                        previewController.dataSource = self
//                        previewController.modalPresentationStyle = .overFullScreen
                        self?.hideKeyboard()
                        previewController.delegate = self
                        self?.previewItem = fileLocationURL
                        self?.inputBarView?.isHidden=true
                        self?.present(previewController, animated: true, completion: {
                        })
                    }else{
                        print("error")
                      //  self?.showAlert(title: "telemed_error_upload_file".localized , subtitle: nil)
                    }
                }
            })
        }
        
        let editNotifier = EditNotifier()
        let dataSource = DefaultChatCollectionDataSource(editNotifier: editNotifier,
                                                         reloadDelegate: messageController,
                                                         editingDelegate: messageController)
        
        dataProvider.delegate = messageController
        
        let messageViewController = ChatViewController(chatController: messageController, dataSource: dataSource, editNotifier: editNotifier)
        messageController.delegate = messageViewController
        let attachButton = messageViewController.inputBarView.attachButton
        
        attachButton.setImage(ImagesHelper.loadImage(resolvedName: "ic_attach_file"), for: .normal)
        attachButton.image = ImagesHelper.loadImage(resolvedName: "ic_attach_file")
        attachButton.title = nil
        let sendButton = messageViewController.inputBarView.sendButton
        
        sendButton.title = nil

        sendButton.image = ImagesHelper.loadImage(resolvedName: "ic_chat_send")
        messageViewController.inputBarView.inputTextView.placeholder = "telemed_chat_placeholder".localized
        messageViewController.view.backgroundColor = TelemedColors.athensGray.uiColor
        
        messageViewController.inputBarView.attachButton.image = ImagesHelper.loadImage(resolvedName: "ic_attach_file")
        messageViewController.inputBarView.attachButton.addTarget(self, action: #selector(attachButtonTapped(_:)), for: .touchUpInside)
        messageViewController.inputBarView.attachButton.onTouchUpInside { [weak self] (item) in
            self?.attachAction(item)
        }
        
        return messageViewController
    }
    
    //attach file
    @objc private func attachButtonTapped(_ sender: UIButton) {
        let permissionVc = ChatPermissionController(nibName: "ChatPermissionController", bundle: Bundle(for: TelemedMainViewController.self))
        permissionVc.modalPresentationStyle = .fullScreen
        self.present(permissionVc, animated: true) {
            permissionVc.buildPermission(.galleryButton)
        }
    }
    
    func chooseIcloud() {
        openDocumentPicker(delegate: self)
    }
    
    func openDocumentPicker(delegate: UIDocumentPickerDelegate) {
        let supportedTypes: [UTType] = [UTType.image, .pdf, .png, .text]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = delegate
        present(documentPicker, animated: true, completion: {
            documentPicker.allowsMultipleSelection = true
            documentPicker.delegate = delegate
        })
    }
    
    // MARK: - need owerride meths
    open func cancelAction() {
        fatalError()
    }
    open func finishAction(isNoOption:Bool) {
       // fatalError()
    }
    open func switchToChat() {
        self.inputBarView?.isHidden=false
        self.inputBarView?.becomeFirstResponder()

    }
    open func switchToCall() {
        self.inputBarView?.isHidden=true
    }
    
    open func setFlugs(audio:UIButton, video:UIButton) {
        fatalError()
     //   self.inputBarView?.isHidden=true
    }
    
    
    // MARK: - private meths
    fileprivate func startDialog() {
        TelemedChatManager.shared.startDialog(sender: sender, recipient: recipient, phone: "") { [weak self] (result) in
            guard let self = self else { return }
            self.reconnectionView.isHidden = true
            switch result {
            case .success((let dialog, let userId)):
                self.chatViewController = self.build(dialog, userId)
                self.switchToChat()
                self.startTimer()
                self.reloadInputViews()
                
                self.postLoad()
            case .failure(let error):
                LogUtils.error(error)
            }
        }
    }
    // MARK:  Keyboard issues
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    private func hideKeyboard() {
        inputBarView?.inputTextView.resignFirstResponder()
    }
    private func showKeyboard() {
        inputBarView?.inputTextView.becomeFirstResponder()
    }
    @objc func dismissKeyboard() {
        hideKeyboard()
    }
    
    
    
    // MARK: - IBactions
    @IBAction open func audioCallAction(_ sender: Any) {
        self.state = .calling
        callViewController.audioCall()
        self.dismissKeyboard()
    }
    @IBAction open func videoCallAction(_ sender: Any) {
        self.state = .calling
        callViewController.videoCall()
        self.dismissKeyboard()
    }
    
    @IBAction open func closeButtonAction(_ sender: Any) {
        finishAction(isNoOption: true)
    }
    
    @IBAction open func backToCallAction(_ sender: Any) {
        backToChatButton.isHidden = true
        height.constant = 0
        switchToCall()

    }
    
    func backToChatAction() {
        backToChatButton.isHidden = false
        height.constant = 40
        switchToChat()
    }
    
    deinit {
        QBRTCClient.instance().remove(self)
    }
    
}

// MARK: - Extentions
// MARK: - QBRTCClientDelegate

extension TelemedMainViewController: QBRTCClientDelegate {
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        guard callViewController.session == nil else { return }
        callViewController.incomingSession(session)
        state = .call
    }
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        guard callViewController.session == session else { return }
        callViewController.acceptedCall(session)
        state = .call
    }
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        callViewController.session = nil
        state = .chat
    }
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        callViewController.session = nil
        state = .chat
    }
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        callViewController.session = nil
        state = .chat
    }
    public func sessionDidClose(_ session: QBRTCSession) {
        callViewController.session = nil
        state = .chat
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension TelemedMainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let originalImage = info[ UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let image = originalImage
            .compressed(with: .medium)?
            .scalled(to: .init(width: 400, height: 400)) {
            self.attachedImage = image
            
            if let url: URL = info[.imageURL] as? URL {
                let fileName = url.lastPathComponent
                sendMessageWithAttachment(patch: url, fileName: fileName)
            }else{
                if let data = self.attachedImage?.jpegData(compressionQuality: 100){
                    let filename = getDocumentsDirectory().appendingPathComponent("image_\(Date().timeIntervalSince1970).jpg")
                    try? data.write(to: filename)
                    sendMessageWithAttachment(patch: filename, fileName: filename.lastPathComponent)
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.inputBarView?.isHidden=false
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func size(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    func sendMessageWithAttachment(patch: URL, fileName: String, mimeType: String = "image/png", type: String = "image") {
        let url = patch
        self.inputBarView?.isHidden=false
        QBRequest.uploadFile(with: url, fileName: fileName, contentType: mimeType, isPublic: false, successBlock: { (response, uploadedBlob) in
            
            let attachment = QBChatAttachment()
            attachment.id = uploadedBlob.uid
            attachment.name = uploadedBlob.name
            attachment.type = type
            
            let message = QBChatMessage()
            message.text = "Attachment"
            message.customParameters["save_to_history"] = true
            message.attachments = [attachment]
            
            if let chatController = self.chatViewController?.chatController {
                chatController.sendMessage(message) { _ in
                    self.inputBarView?.isHidden=false
                }
            }
        }, statusBlock: { (request, status)  in
            print(status)
        }, errorBlock: { (response) in
            print(response)
        })
    }
}


//MARK:- QLPreviewController Datasource
extension TelemedMainViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    public func previewControllerDidDismiss(_ controller: QLPreviewController) {
        inputBarView?.isHidden = false
    }
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        return self.previewItem as QLPreviewItem
    }
}

extension TelemedMainViewController: UIDocumentPickerDelegate {
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.inputBarView?.isHidden=false
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let newUrls = urls.compactMap { (url: URL) -> URL? in
            // Create file URL to temporary folder
            var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            // Apend filename (name+extension) to URL
            tempURL.appendPathComponent(url.lastPathComponent)
            do {
                // If file with same name exists remove it (replace file with new one)
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(atPath: tempURL.path)
                }
                // Move file from app_id-Inbox to tmp/filename
                try FileManager.default.moveItem(atPath: url.path, toPath: tempURL.path)
                return tempURL
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        if let url = newUrls.first {
            
            let name = "\(Int.random(in: 1..<100000000))"
            
            sendMessageWithAttachment(patch: url, fileName: "file_" + name + ".\(url.pathExtension)", mimeType: url.absoluteString.mimeType() , type: "file")
        }
    }
}
