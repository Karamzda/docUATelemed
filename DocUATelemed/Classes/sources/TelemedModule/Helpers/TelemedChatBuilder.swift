//
//  TelemedChatBuilder.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 05.10.2022.
//

import UIKit
import ChatLayout
import Quickblox
import QuickLook

//class TelemedChatBuilder {
//    public static func build(_ dialog: QBChatDialog, _ userId: UInt,
//                    openAttachCompletion:  ((_ url: URL, _ id:String) -> Void)?) -> ChatViewController {
//        let dataProvider = QuickBloxDataProvider(dialog: dialog, receiverId: userId)
//        let messageController = DefaultChatController(dataProvider: dataProvider, userId: Int(userId))
//        messageController.openAttachAction = openAttachCompletion
//        
//        let editNotifier = EditNotifier()
//        let dataSource = DefaultChatCollectionDataSource(editNotifier: editNotifier,
//                                                         reloadDelegate: messageController,
//                                                         editingDelegate: messageController)
//        
//        dataProvider.delegate = messageController
//        
//        let messageViewController = ChatViewController(chatController: messageController, dataSource: dataSource, editNotifier: editNotifier)
//        messageController.delegate = messageViewController
//        let attachButton = messageViewController.inputBarView.attachButton
//        attachButton.setImage(UIImage(resolvedName: "ic_attach_file"), for: .normal)
//        attachButton.image = UIImage(resolvedName: "ic_attach_file")
//        attachButton.title = nil
//        let sendButton = messageViewController.inputBarView.sendButton
//        
//        sendButton.title = nil
//        sendButton.image = UIImage(resolvedName: "ic_chat_send")
//        messageViewController.inputBarView.inputTextView.placeholder = "telemed_chat_placeholder".localized
//        //        messageViewController.view.backgroundColor = .athensGray100
////        messageViewController.inputBarView.attachButton.image = UIImage(resolvedName: "ic_attach_file")
////        messageViewController.inputBarView.attachButton.addTarget(self, action: #selector(attachButtonTapped(_:)), for: .touchUpInside)
////        messageViewController.inputBarView.attachButton.onTouchUpInside { [weak self] (item) in
////            self?.attachAction(item)
////        }
//        
////        { [weak self]  (result,id) in
////            FilesDownloader.downloadfile(filename:"img_\(id).jpg",url:result,completion: {(success, fileLocationURL) in
////                DispatchQueue.main.async {
////                    if success {
////                        let previewController = QLPreviewController()
////                        previewController.dataSource = self
////                        self?.previewItem = fileLocationURL
////                        self?.present(previewController, animated: true, completion: {
////                            self?.inputBarView?.isHidden=false
////                        })
////                    }else{
////                        print("error")
////                        //  self?.showAlert(title: "telemed_error_upload_file".localized , subtitle: nil)
////                    }
////                }
////            })
////        }
//        
//        return messageViewController
//    }
//}
