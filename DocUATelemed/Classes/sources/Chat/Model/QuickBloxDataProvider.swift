//
//  QuickBloxDataProvider.swift
//  DocUAChat
//
//  Created by severehed on 08.04.2021.
//

import Foundation
import Quickblox
import UIKit.UIImage

extension RawMessage {
    init?(_ qbMessage: QBChatMessage) {
        guard let id = qbMessage.id else {
//            LogUtils.error("Wrong qbMessage")
            return nil
        }
        self.id = id
        self.date = qbMessage.dateSent ?? Date()
        self.data = .text(qbMessage.text ?? "")

        self.userId = Int(qbMessage.senderID)
        
        if let type = qbMessage.attachments?.first?.type, type == "image",
           let fileId = qbMessage.attachments?.first?.id,
           let urlString = QBCBlob.privateUrl(forFileUID: fileId),
           let url: URL = URL(string: urlString)
        {
            let imageSourse: ImageMessageSource = .imageURL(url)
            self.data = .image(imageSourse)
        }else if let type = qbMessage.attachments?.first?.type, type == "file",
                 let fileId = qbMessage.attachments?.first?.id,
                 let urlString = QBCBlob.privateUrl(forFileUID: fileId),
                 let url: URL = URL(string: urlString) {
            let size = qbMessage.attachments?.first?.customParameters?["size"]
            let sizeDouble = Double(size ?? "0")
            self.data = .file(url: url, name: qbMessage.attachments?.first?.name ?? "", size: sizeDouble ?? 0)
        } else {
            self.data = .text(qbMessage.text ?? "")
        }
    }
}

extension QBChatMessage {
    
    convenience init(_ message: RawMessage) {
        self.init()
        switch message.data {
        case .text(let string): self.text = string
        case .url(let url):
            self.text = url.absoluteString
            
        case .image(let imageSourse):
            switch imageSourse {
            case .image(let image):
                prepareImageAttachment(image: image) { attachment in
                    if let attachment = attachment {
                        self.attachments?.append(attachment)
                    }
                }
            case .imageURL(let url):
                prepareImageAttachment(url: url) { attachment in
                    if let attachment = attachment {
                        self.attachments?.append(attachment)
                    }
                }
            }
            self.text = "[IMAGE]"
        case let .file(url, _, _):
            prepareImageAttachment(url: url) { attachment in
                if let attachment = attachment {
                    self.attachments?.append(attachment)
                }
            }
            self.text = "[FILE]"
        }
        self.customParameters["save_to_history"] = true
    }
        
    func prepareImageAttachment(image: UIImage, completion: @escaping (QBChatAttachment?)->Void) {
        image.getTempUrl { (url) in
            QBRequest.uploadFile(with: url,
                                 fileName: url.lastPathComponent,
                                 contentType: "image/png",
                                 isPublic: true,
                                 successBlock: { (response, uploadedBlob) in
                let attachment = QBChatAttachment()
                attachment.id = uploadedBlob.uid
                attachment.name = uploadedBlob.name
                attachment.type = "image"
                attachment.url = uploadedBlob.publicUrl()
                completion(attachment)
            }, statusBlock: { (request, status)  in
                //TODO:
            }, errorBlock: { (response) in
                //TODO:
            })
        }
    }
//TODO: Refactor
    func prepareImageAttachment(url: URL, completion: @escaping (QBChatAttachment?)->Void) {
        QBRequest.uploadFile(with: url,
                             fileName: url.lastPathComponent,
                             contentType: "image/png",
                             isPublic: true,
                             successBlock: { (response, uploadedBlob) in
                                let attachment = QBChatAttachment()
                                attachment.id = uploadedBlob.uid
                                attachment.name = uploadedBlob.name
                                attachment.type = "image"
                                attachment.url = uploadedBlob.publicUrl()
                                completion(attachment)
                             }, statusBlock: { (request, status)  in
                                //TODO:
                             }, errorBlock: { (response) in
                                //TODO:
                             })
    }
    
}

public final class QuickBloxDataProvider: NSObject, DefaultChatDataProvider, QBChatDelegate {
    
    public weak var delegate: DefaultChatDataProviderDelegate?
    
    private var messageTimer: Timer?
    private var typingTimer: Timer?
    private var startingTimestamp = Date().timeIntervalSince1970
    private var typingState: TypingState = .idle
    private var lastMessageIndex: Int = 0
    private var lastReadUUID: UUID?
    private var lastReceivedUUID: UUID?
    private let dispatchQueue = DispatchQueue.global(qos: .userInteractive)
    private let enableTyping = true
    private let enableNewMessages = true
    private let enableRichContent = true
    private let dialog: QBChatDialog
    private let receiverId: UInt
    
    // MARK: - Init
    
    public init(dialog: QBChatDialog, receiverId: UInt) {
        self.dialog = dialog
        self.receiverId = receiverId
        super.init()
        
        QBChat.instance.addDelegate(self)
    }
    
    deinit {
        QBChat.instance.removeDelegate(self)
        self.dialog.leave(completionBlock: nil)
    }
    
    // MARK: Public Methods
    public func loadInitialMessages(completion: @escaping ([RawMessage]) -> Void) {
        let page = QBResponsePage(limit: 100, skip: 0)
        let extendedRequest = ["sort_desc": "date_sent"]
        QBRequest.messages(withDialogID: self.dialog.id!, extendedRequest: extendedRequest, for: page, successBlock: { (response, messages, page) in
            let result = messages.compactMap({ RawMessage($0) })
            completion(result)
        }, errorBlock: { (response) in
//            LogUtils.error(response)
            completion([])
        })
    }
    
    public func loadPreviousMessages(completion: @escaping ([RawMessage]) -> Void) {
        completion([])
    }
    
    public func stop() {
        dialog.leave(completionBlock: nil)
    }
    
        public func sendMessage(_ message: RawMessage, completion: @escaping (Result<RawMessage, Error>) -> Void) {
            let qbMessage = QBChatMessage(message)
            //var rawMessage = RawMessage(qbMessage)!
            var rawMessage = message
            rawMessage.status = .sending
            completion(.success(rawMessage))
    
            dialog.send(qbMessage) { [weak self] (error) in
                guard let self = self else { return }
                if error != nil {
                    self.delegate?.failed(messageId: rawMessage.id)
                }
                else {
                    self.delegate?.sent(messageId: rawMessage.id)
                }
            }
        }
    
    public func sendMessage(_ message: QBChatMessage, completion: @escaping (Result<RawMessage, Error>) -> Void) {
        let message = message
        var rawMessage = RawMessage(message)!
        rawMessage.status = .sending
        completion(.success(rawMessage))
        dialog.send(message) { [weak self] (error) in
            guard let self = self else { return }
            if error != nil {
                self.delegate?.failed(messageId: rawMessage.id)
            }
            else {
                self.delegate?.sent(messageId: rawMessage.id)
            }
        }
    }
    
    public func markAsRead(_ messageId: String) {
        //        let qbMessage = QBChatMessage()
        //        qbMessage.id = messageId
        //        qbMessage.dialogID = dialog.id
        //        QBChat.instance.read(qbMessage) { (error) in
        //            LogUtils.error(error)
        //        }
    }
    
    public func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        guard dialogID == dialog.id else { return }
        delegate?.delivered(messageId: messageID)
    }
    
    public func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        guard dialogID == dialog.id else { return }
        delegate?.read(messageId: messageID)
    }
    
    public func chatDidReceive(_ message: QBChatMessage) {
        guard message.dialogID == dialog.id else { return }
        guard let rawMessage = RawMessage(message) else {
//            LogUtils.warn("received not supported message")
            return
        }
        delegate?.received(messages: [rawMessage])
        QBChat.instance.mark(asDelivered: message)
    }
    
    public func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        return
//        guard dialogID == dialog.id else {
//            return
//        }
//        guard var message = RawMessage(message) else {
////            LogUtils.warn("received not supported message")
//            return
//        }
//        //        message.status = .received
//        delegate?.received(messages: [message])
    }
}

extension UIImage {
    func getTempUrl( complition: @escaping (URL)->Void ) {
//        guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage.png")
//        else { return }
//        
//        let pngData = self.pngData();
//        do {
//            try pngData?.write(to: imageURL)
//            complition(imageURL)
//        } catch {
//            print(#function)
//            print("can't save TempImage.png")
//        }
    }
}
