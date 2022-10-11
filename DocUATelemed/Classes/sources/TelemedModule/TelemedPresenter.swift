//
//  TelemedPresenter.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 05.10.2022.
//

import Quickblox
import QuickbloxWebRTC
import QuickLook
import Network

public class TelemedPresenter: NSObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    weak var view: TelemedViewController!
    public var recipient: TelemedChatUser?
    public var sender: TelemedChatUser?
    
    var state: TelemedState = .chat {
        didSet {
            stateChanged(state: state)
        }
    }
    
    func viewHasAppeared() {
        UIApplication.shared.isIdleTimerDisabled = true
        monitor.start(queue: queue)
    }
    
    func viewHasDissapeared() {
        UIApplication.shared.isIdleTimerDisabled = false
        monitor.cancel()
    }
    
    func viewHasLoaded() {
        startDialog()
    }
    
    private func stateChanged(state: TelemedState) {
        
    }
    
    func startDialog() {
//        guard let recipient = recipient, let sender = sender else { return }
        
//        TelemedChatManager.shared.startDialog(sender: sender, recipient: recipient, phone: "") { [weak self] (result) in
//            guard let self = self else { return }
//            switch result {
//            case .success((let dialog, let userId)):
////                self.switchToChat()
//                self.startTimer()
//                self.reloadInputViews()
//                
//                self.postLoad()
//            case .failure(let error):
//                break
//            }
//        }
    }
}

extension TelemedPresenter: QBRTCClientDelegate {
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
//        guard callViewController.session == nil else { return }
//        callViewController.incomingSession(session)
        state = .call
    }
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
//        guard callViewController.session == session else { return }
//        callViewController.acceptedCall(session)
        state = .call
    }
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
//        callViewController.session = nil
        state = .chat
    }
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
//        callViewController.session = nil
        state = .chat
    }
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
//        callViewController.session = nil
        state = .chat
    }
    public func sessionDidClose(_ session: QBRTCSession) {
//        callViewController.session = nil
        state = .chat
    }
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
    
}
