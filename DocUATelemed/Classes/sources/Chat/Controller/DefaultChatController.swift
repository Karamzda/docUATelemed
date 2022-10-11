//
// ChatLayout
// DefaultChatController.swift
//

import ChatLayout
import Foundation
import Quickblox


public final class DefaultChatController: ChatController {

    public weak var delegate: ChatControllerDelegate?
    private let dataProvider: DefaultChatDataProvider
    private var typingState: TypingState = .idle
    private let dispatchQueue = DispatchQueue(label: "DefaultChatController", qos: .userInteractive)
    private var lastReadUUID: String?
    private var lastReceivedUUID: String?
    private let userId: Int

    var messages: [RawMessage] = []
    
    public var openAttachAction: ((_ url: URL, _ id:String) -> Void)?
    public var openFile: ((_ url: URL, _ name:String) -> Void)?

    public init(dataProvider: DefaultChatDataProvider, userId: Int) {
        self.dataProvider = dataProvider
        self.userId = userId
    }

    public func loadInitialMessages(completion: @escaping ([Section]) -> Void) {
        dataProvider.loadInitialMessages { messages in
            self.appendConvertingToMessages(messages)
            self.propagateLatestMessages { sections in
                completion(sections)
            }
        }
    }

    public func loadPreviousMessages(completion: @escaping ([Section]) -> Void) {
        dataProvider.loadPreviousMessages(completion: { messages in
            self.appendConvertingToMessages(messages)
            self.propagateLatestMessages { sections in
                completion(sections)
            }
        })
    }

    public func sendMessage(_ data: Message.Data, completion: @escaping ([Section]) -> Void) {
        let message = RawMessage(id: UUID().uuidString, date: Date(), data: convert(data), userId: userId)
        dataProvider.sendMessage(message) { [weak self] (result) in
            guard let self = self else { return }
            if case .success(let message) = result {
                self.messages.append(message)
                self.propagateLatestMessages { sections in
                    completion(sections)
                }
            }
        }
    }
    
    public func sendMessage(_ message: QBChatMessage, completion: @escaping ([Section]) -> Void) {
        dataProvider.sendMessage(message) { [weak self] (result) in
            guard let self = self else { return }
            if case .success(let message) = result {
                self.messages.append(message)
                self.propagateLatestMessages { sections in
                    completion(sections)
                }
            }
        }
    }
    
    public func willDisplay(_ cell: Cell) {
        switch cell {
        case .messageGroup(let group):
            if group.type == .incoming {
                dataProvider.markAsRead(group.id)
            }
        case .message(let message, bubbleType: _):
            if message.type == .incoming, message.status == .received {
                dataProvider.markAsRead(message.id)
            }
        default:
            break
        }
    }

    private func appendConvertingToMessages(_ rawMessages: [RawMessage]) {
        var messages = self.messages.reduce([String: RawMessage]()) { (dict, message) -> [String: RawMessage] in
            var dict = dict
            dict[message.id] = message
            return dict
        }
        
        rawMessages.forEach({
            messages[$0.id] = $0
        })
        
        self.messages = messages.values.sorted(by: { $0.date.timeIntervalSince1970 < $1.date.timeIntervalSince1970 })
    }

    private func propagateLatestMessages(completion: @escaping ([Section]) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let cells: [Cell] = self.messages
                .map({
                    let message = Message(id: $0.id,
                                          date: $0.date,
                                          data: self.convert($0.data),
                                          owner: TelemedChatManager.shared.user(id: $0.userId),
                                          type: $0.userId == self.userId ? .outgoing : .incoming,
                                          status: $0.status)
                    let cell = Cell.message(message, bubbleType: .tailed)
                    return cell
                })

            DispatchQueue.main.async { [weak self] in
                guard self != nil else {
                    return
                }
                completion([Section(id: 0, title: "", cells: Array(cells))])
            }
        }

    }

    private func convert(_ data: Message.Data) -> RawMessage.Data {
        switch data {
        case let .url(url, isLocallyStored: _):
            return .url(url)
        case let .image(source, isLocallyStored: _):
            return .image(source)
        case let .text(text):
            return .text(text)
        case let .file(url, name, size):
            return .file(url: url, name: name, size: size)
        }
    }

    private func convert(_ data: RawMessage.Data) -> Message.Data {
        switch data {
        case let .url(url):
            let isLocallyStored: Bool
            if #available(iOS 13, *) {
                isLocallyStored = metadataCache.isEntityCached(for: url)
            } else {
                isLocallyStored = false // TODO: remove bogus
            }
            return .url(url, isLocallyStored: isLocallyStored)
        case let .image(source):
            func isPresentLocally(_ source: ImageMessageSource) -> Bool {
                switch source {
                case .image:
                    return true
                case let .imageURL(url):
                    return imageCache.isEntityCached(for: CacheableImageKey(url: url))
                }
            }
            return .image(source, isLocallyStored: isPresentLocally(source))
        case let .text(text):
            return .text(text)
        case let .file(url, name, size):
            return .file(url: url, name: name, size: size)
        }
    }

}

extension DefaultChatController: DefaultChatDataProviderDelegate {
    public func sent(messageId: String) {
        guard let index = self.messages.firstIndex(where: { $0.id == messageId }) else { return }
        var message = self.messages[index]
        message.status = .sent
        self.messages[index] = message
        propagateLatestMessages { (sections) in
            self.delegate?.update(with: sections)
        }
    }
    
    public func delivered(messageId: String) {
        guard let index = self.messages.firstIndex(where: { $0.id == messageId }) else { return }
        var message = self.messages[index]
        message.status = .received
        self.messages[index] = message
        propagateLatestMessages { (sections) in
            self.delegate?.update(with: sections)
        }
    }
    
    public func failed(messageId: String) {
        guard let index = self.messages.firstIndex(where: { $0.id == messageId }) else { return }
        var message = self.messages[index]
        message.status = .failed
        self.messages[index] = message
        propagateLatestMessages { (sections) in
            self.delegate?.update(with: sections)
        }
    }
    
    public func read(messageId: String) {
        guard let index = self.messages.firstIndex(where: { $0.id == messageId }) else { return }
        var message = self.messages[index]
        message.status = .read
        self.messages[index] = message
        propagateLatestMessages { (sections) in
            self.delegate?.update(with: sections)
        }
    }

    public func received(messages: [RawMessage]) {
        appendConvertingToMessages(messages)
        self.propagateLatestMessages { sections in
            self.delegate?.update(with: sections)
        }
    }

    public func lastReadIdChanged(to id: String) {
        
    }

    public func lastReceivedIdChanged(to id: String) {
        
    }
}

extension DefaultChatController: ReloadDelegate {
    public func saveFile(url: URL, name: String) {
        openFile?(url, name)
    }
    

    public func reloadMessage(with id: String) {
        propagateLatestMessages(completion: { sections in
            self.delegate?.update(with: sections)
        })
    }
    
    public func openAttach(url: URL,id:String) {
        openAttachAction?(url, id)

    }

    
}

extension DefaultChatController: EditingAccessoryControllerDelegate {

    public func deleteMessage(with id: String) {
        messages = Array(messages.filter { $0.id != id })
        propagateLatestMessages(completion: { sections in
            self.delegate?.update(with: sections)
        })
    }

}
