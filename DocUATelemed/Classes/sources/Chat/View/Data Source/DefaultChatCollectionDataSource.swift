//
// ChatLayout
// DefaultChatCollectionDataSource.swift
//

import ChatLayout
import Foundation
import UIKit

typealias TextMessageCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, CellLayoutContainerView<VoidViewFactory, ImageMaskedView<TextMessageView>, StatusView>>>
@available(iOS 13, *)
typealias URLCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, CellLayoutContainerView<VoidViewFactory, ImageMaskedView<URLView>, StatusView>>>
typealias ImageCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, CellLayoutContainerView<VoidViewFactory, ImageMaskedView<ChatImageView>, StatusView>>>
typealias FileCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, CellLayoutContainerView<VoidViewFactory, ImageMaskedView<FileView>, StatusView>>>
typealias TitleCollectionCell = ContainerCollectionViewCell<UILabel>
typealias TypingIndicatorCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, CellLayoutContainerView<VoidViewFactory, ImageMaskedView<TextMessageView>, VoidViewFactory>>>

typealias TextTitleView = ContainerCollectionReusableView<UILabel>

public final class DefaultChatCollectionDataSource: NSObject, ChatCollectionDataSource {

    private unowned var reloadDelegate: ReloadDelegate

    private unowned var editingDelegate: EditingAccessoryControllerDelegate

    private let editNotifier: EditNotifier

    public var sections: [Section] = [] {
        didSet {
            oldSections = oldValue
        }
    }

    private var oldSections: [Section] = []

    public init(editNotifier: EditNotifier, reloadDelegate: ReloadDelegate, editingDelegate: EditingAccessoryControllerDelegate) {
        self.reloadDelegate = reloadDelegate
        self.editingDelegate = editingDelegate
        self.editNotifier = editNotifier
    }

    public func prepare(with collectionView: UICollectionView) {
        collectionView.register(TextMessageCollectionCell.self, forCellWithReuseIdentifier: TextMessageCollectionCell.reuseIdentifier)
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.reuseIdentifier)
        collectionView.register(TitleCollectionCell.self, forCellWithReuseIdentifier: TitleCollectionCell.reuseIdentifier)
        collectionView.register(TypingIndicatorCollectionCell.self, forCellWithReuseIdentifier: TypingIndicatorCollectionCell.reuseIdentifier)
        collectionView.register(FileCollectionCell.self, forCellWithReuseIdentifier: FileCollectionCell.reuseIdentifier)
        collectionView.register(TextTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TextTitleView.reuseIdentifier)
        collectionView.register(TextTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TextTitleView.reuseIdentifier)
        if #available(iOS 13.0, *) {
            collectionView.register(URLCollectionCell.self, forCellWithReuseIdentifier: URLCollectionCell.reuseIdentifier)
        }
    }

    private func createTextCell(collectionView: UICollectionView, messageId: String, indexPath: IndexPath, text: String, alignment: ChatItemAlignment, user: TelemedChatUser, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType, date: Date) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextMessageCollectionCell.reuseIdentifier, for: indexPath) as! TextMessageCollectionCell
        setupMessageContainerView(cell.customView, messageId: messageId, alignment: alignment)
        setupCellLayoutView(cell.customView.customView, user: user, alignment: alignment, bubble: bubbleType, status: status)

        let bubbleView = cell.customView.customView.customView
        let controller = TextMessageController(text: text,
                                               type: messageType,
                                               bubbleController: buildDefaultBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType, user: user, date: date))
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView

        return cell
    }

    @available(iOS 13, *)
    private func createURLCell(collectionView: UICollectionView, messageId: String, indexPath: IndexPath, url: URL, alignment: ChatItemAlignment, user: TelemedChatUser, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType, date: Date) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: URLCollectionCell.reuseIdentifier, for: indexPath) as! URLCollectionCell
        setupMessageContainerView(cell.customView, messageId: messageId, alignment: alignment)
        setupCellLayoutView(cell.customView.customView, user: user, alignment: alignment, bubble: bubbleType, status: status)

        let bubbleView = cell.customView.customView.customView
        let controller = URLController(url: url,
                                       messageId: messageId,
                                       bubbleController: buildDefaultBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType, user: user, date: date))
        
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        controller.delegate = reloadDelegate
        cell.delegate = bubbleView.customView

        return cell
    }

    private func createImageCell(collectionView: UICollectionView, messageId: String, indexPath: IndexPath, alignment: ChatItemAlignment, user: TelemedChatUser, source: ImageMessageSource, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType, date: Date) -> ImageCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.reuseIdentifier, for: indexPath) as! ImageCollectionCell

        setupMessageContainerView(cell.customView, messageId: messageId, alignment: alignment)
        setupCellLayoutView(cell.customView.customView, user: user, alignment: alignment, bubble: bubbleType, status: status)

        let bubbleView = cell.customView.customView.customView
        let controller = ImageController(source: source,
                                         messageId: messageId,
                                         bubbleController: buildDefaultBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType, user: user, date: date))

        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView

        return cell
    }
    
    private func createFileCell(collectionView: UICollectionView, messageId: String, indexPath: IndexPath, alignment: ChatItemAlignment, user: TelemedChatUser, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType, date: Date, url: URL, name: String, size: Double) -> FileCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileCollectionCell.reuseIdentifier, for: indexPath) as! FileCollectionCell

        setupMessageContainerView(cell.customView, messageId: messageId, alignment: alignment)
        setupCellLayoutView(cell.customView.customView, user: user, alignment: alignment, bubble: bubbleType, status: status)
        let bubbleView = cell.customView.customView.customView
        
        let controller = FileViewController(url: url, text: name, type: messageType,
                                            bubbleController: buildDefaultBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType, user: user, date: date))
        
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        bubbleView.customView.setup(with: url, name: name, size: size)

        return cell
    }

    private func createGroupTitle(collectionView: UICollectionView, indexPath: IndexPath, alignment: ChatItemAlignment, title: String) -> TitleCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionCell.reuseIdentifier, for: indexPath) as! TitleCollectionCell
        cell.customView.text = title
        cell.customView.preferredMaxLayoutWidth = (collectionView.collectionViewLayout as? CollectionViewChatLayout)?.layoutFrame.width ?? collectionView.frame.width
        cell.customView.textColor = .gray
        cell.customView.numberOfLines = 0
        cell.customView.font = .preferredFont(forTextStyle: .caption2)
        cell.contentView.layoutMargins = UIEdgeInsets(top: 2, left: 40, bottom: 2, right: 40)
        return cell
    }

    private func createDateTitle(collectionView: UICollectionView, indexPath: IndexPath, alignment: ChatItemAlignment, title: String) -> TitleCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionCell.reuseIdentifier, for: indexPath) as! TitleCollectionCell
        cell.customView.preferredMaxLayoutWidth = (collectionView.collectionViewLayout as? CollectionViewChatLayout)?.layoutFrame.width ?? collectionView.frame.width
        cell.customView.text = title
        cell.customView.textColor = .gray
        cell.customView.numberOfLines = 0
        cell.customView.font = .preferredFont(forTextStyle: .caption2)
        cell.contentView.layoutMargins = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return cell
    }

    private func setupMessageContainerView<CustomView>(_ messageContainerView: MessageContainerView<EditingAccessoryView, CustomView>, messageId: String, alignment: ChatItemAlignment) {
        messageContainerView.alignment = alignment
        if let accessoryView = messageContainerView.accessoryView {
            editNotifier.add(delegate: accessoryView)
            accessoryView.setIsEditing(editNotifier.isEditing)

            let controller = EditingAccessoryController(messageId: messageId)
            controller.view = accessoryView
            controller.delegate = editingDelegate
            accessoryView.setup(with: controller)
        }
    }

    private func setupCellLayoutView<CustomView>(_ cellView: CellLayoutContainerView<VoidViewFactory, CustomView, StatusView>,
                                                 user: TelemedChatUser,
                                                 alignment: ChatItemAlignment,
                                                 bubble: Cell.BubbleType,
                                                 status: MessageStatus) {
        cellView.alignment = .bottom
        cellView.leadingView?.isHiddenSafe = !alignment.isIncoming
        cellView.leadingView?.alpha = alignment.isIncoming ? 1 : 0
        cellView.trailingView?.isHiddenSafe = alignment.isIncoming
        cellView.trailingView?.alpha = alignment.isIncoming ? 0 : 1
        cellView.trailingView?.setup(with: status)
    }

    private func buildDefaultBubbleController<CustomView>(for bubbleView: ImageMaskedView<CustomView>, messageType: MessageType, bubbleType: Cell.BubbleType, user: TelemedChatUser, date: Date) -> BubbleController {
        let bubbleController = DefaultBubbleController(bubbleView: bubbleView, type: messageType, bubbleType: bubbleType, user: user, date: date)
        return bubbleController
    }

}

extension DefaultChatCollectionDataSource: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sections[indexPath.section].cells[indexPath.item]
        switch cell {
        case let .message(message, bubbleType: bubbleType):
            switch message.data {
            case let .text(text):
                let cell = createTextCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, text: text, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, date: message.date)
                return cell
            case let .url(url, isLocallyStored: _):
                if #available(iOS 13.0, *) {
                    return createURLCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, url: url, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, date: message.date)
                } else {
                    return createTextCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, text: url.absoluteString, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, date: message.date)
                }
            case let .image(source, isLocallyStored: _):
                let cell = createImageCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, alignment: cell.alignment, user: message.owner, source: source, bubbleType: bubbleType, status: message.status, messageType: message.type, date: message.date)
                return cell
            case let .file(url, name, size):
                let cell = createFileCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, date: message.date, url: url, name: name, size: size)
                
                return cell
            }
        case let .messageGroup(group):
            let cell = createGroupTitle(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, title: group.title)
            return cell
        case let .date(group):
            let cell = createDateTitle(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, title: group.value)
            return cell
        default:
            fatalError()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: TextTitleView.reuseIdentifier,
                                                                       for: indexPath) as! TextTitleView
            view.customView.text = sections[indexPath.section].title
            view.customView.preferredMaxLayoutWidth = 300
            view.customView.textColor = .lightGray
            view.customView.numberOfLines = 0
            view.customView.font = .preferredFont(forTextStyle: .caption2)
            view.isHidden = false
            return view
        case UICollectionView.elementKindSectionFooter:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: TextTitleView.reuseIdentifier,
                                                                       for: indexPath) as! TextTitleView
            view.customView.text = "Made with ChatLayout"
            view.customView.preferredMaxLayoutWidth = 300
            view.customView.textColor = .lightGray
            view.customView.numberOfLines = 0
            view.customView.font = .preferredFont(forTextStyle: .caption2)
            view.isHidden = true
            return view
        default:
            fatalError()
        }
    }

}

extension DefaultChatCollectionDataSource: ChatLayoutDelegate {

    public func shouldPresentHeader(_ chatLayout: CollectionViewChatLayout, at sectionIndex: Int) -> Bool {
        return true
    }

    public func shouldPresentFooter(_ chatLayout: CollectionViewChatLayout, at sectionIndex: Int) -> Bool {
        return true
    }

    public func sizeForItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath) -> ItemSize {
        switch kind {
        case .cell:
            let item = sections[indexPath.section].cells[indexPath.item]
            switch item {
            case let .message(message, bubbleType: _):
                switch message.data {
                case .text:
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 36))
                case let .image(_, isLocallyStored: isDownloaded):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: isDownloaded ? 120 : 80))
                case let .url(_, isLocallyStored: isDownloaded):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: isDownloaded ? 60 : 36))
                case .file:
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 100))
                }
            case .date:
                return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 18))
            case .messageGroup:
                return .estimated(CGSize(width: chatLayout.layoutFrame.width / 3, height: 18))
            case .deliveryStatus:
                return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 18))
            }
        case .footer, .header:
            return .auto
        }
    }

    public func alignmentForItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath) -> ChatItemAlignment {
        switch kind {
        case .header:
            return .center
        case .cell:
            let item = sections[indexPath.section].cells[indexPath.item]
            switch item {
            case .date:
                return .center
            case .message, .deliveryStatus:
                return .fullWidth
            case .messageGroup:
                return .leading
            }
        case .footer:
            return .trailing
        }
    }

    public func initialLayoutAttributesForInsertedItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: ChatLayoutAttributes, on state: InitialAttributesRequestType) {
        originalAttributes.alpha = 0
        guard state == .invalidation,
            kind == .cell else {
            return
        }
        switch sections[indexPath.section].cells[indexPath.item] {
        // Uncomment to see the effect
        case .messageGroup:
            originalAttributes.center.x -= originalAttributes.frame.width
        case let .message(message, bubbleType: _):
            originalAttributes.transform = .init(scaleX: 0.9, y: 0.9)
            originalAttributes.transform = originalAttributes.transform.concatenating(.init(rotationAngle: message.type == .incoming ? -0.05 : 0.05))
            originalAttributes.center.x += (message.type == .incoming ? -20 : 20)
        
        default:
            break
        }
    }

    public func finalLayoutAttributesForDeletedItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: ChatLayoutAttributes) {
        originalAttributes.alpha = 0
        guard kind == .cell else {
            return
        }
        switch oldSections[indexPath.section].cells[indexPath.item] {
        // Uncomment to see the effect
        case .messageGroup:
            originalAttributes.center.x -= originalAttributes.frame.width
        case let .message(message, bubbleType: _):
            originalAttributes.transform = .init(scaleX: 0.9, y: 0.9)
            originalAttributes.transform = originalAttributes.transform.concatenating(.init(rotationAngle: message.type == .incoming ? -0.05 : 0.05))
            originalAttributes.center.x += (message.type == .incoming ? -20 : 20)
        default:
            break
        }
    }

}
