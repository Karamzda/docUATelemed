//
//  TelemedManager.swift
//  DocUAPatient
//
//  Created by severehed on 29.03.2021.
//

import Foundation
import Quickblox
import os
import QuickbloxWebRTC

public enum TelemedError: Error {
    case unauthorized
    case other(error: Error?)
}

public struct QuickBloxConfig {
    public init(applicationId: UInt, authKey: String, authSecret: String, accountKey: String? = nil, api: String, chatApi: String) {
        self.applicationId = applicationId
        self.authKey = authKey
        self.authSecret = authSecret
        self.accountKey = accountKey
        self.api = api
        self.chatApi = chatApi
    }
    
    let applicationId: UInt
    let authKey: String
    let authSecret: String
    let accountKey: String?
    
    let api: String
    let chatApi: String
}

public enum DocUAChatAppearance: UInt {
    case patient
    case doctor
    
    var assetPrefix: String {
        switch self {
        case .patient: return "pat"
        case .doctor: return "doc"
        }
    }
}

public var Appearence: DocUAChatAppearance {
    get {
        return TelemedChatManager.appearance
    }
}

// MARK: - Telemed chat manager

public final class TelemedChatManager {
	private var logger = Logger(subsystem: "com.doconline.healthcare",
								category: "\n🔭📺💬👨🏻‍⚕️ TelemedChatManager")
    public typealias TokenGetter = () -> String?
    public typealias TokenRefresher = (_ completion: @escaping () -> Void) -> Void
    public typealias LocalizationResolver = (String) -> String
    public static var shared: TelemedChatManager!
    public private(set) weak var dialog: QBChatDialog?
    
    class var appearance: DocUAChatAppearance {
        get {
            return shared.appearance // TODO: Why?
        }
    }
    
    let tokenGetter: TokenGetter
    let tokenRefresher: TokenRefresher
    let appearance: DocUAChatAppearance
    let localizationResolver: LocalizationResolver
    let config: QuickBloxConfig
    var sender: TelemedChatUser!
    var recipient: TelemedChatUser!
    
    init(appearance: DocUAChatAppearance,
         config: QuickBloxConfig,
         tokenGetter: @escaping TokenGetter,
         tokenRefresher: @escaping TokenRefresher,
         localizationResolver: @escaping LocalizationResolver) {
        self.appearance = appearance
        self.tokenGetter = tokenGetter
        self.tokenRefresher = tokenRefresher
        self.config = config
        self.localizationResolver = localizationResolver
    }
    
    public class func configure(appearance: DocUAChatAppearance,
                                config: QuickBloxConfig,
                                tokenGetter: @autoclosure @escaping TokenGetter,
                                tokenRefresher: @escaping TokenRefresher,
                                localizationResolver: @escaping LocalizationResolver) {
        shared = TelemedChatManager(appearance: appearance, config: config,
                                    tokenGetter: tokenGetter,
                                    tokenRefresher: tokenRefresher,
                                    localizationResolver: localizationResolver)
		//logger.error("Chat configured wrong, user ids doesn't match")
		shared.logger.info("\n Will drop to configure QuickBlox")
        shared.configureQuickBlox(config: config)
    }
    
    public func logout() { // TODO: why public?
        QBRequest.logOut { (response) in
        } errorBlock: { (response) in
        }
    }
    
    func user(id: Int) -> TelemedChatUser {
        guard let user = [sender, recipient].first(where: { $0.id == id }) else {
			logger.error("Chat configured wrong, user ids doesn't match")
            fatalError("Chat configured wrong, user ids doesn't match")
            //  Stub for debug
            //  sender.id = 34759
            //  return sender
        }
        return user
    }
    
    // MARK: StartDialog
    public func startDialog(sender: TelemedChatUser,
                     recipient: TelemedChatUser,
                     phone: String,
                            completion: @escaping (Swift.Result<(QBChatDialog, UInt), TelemedError>) -> Void) {
        
        self.sender = sender
        self.recipient = recipient
        
        let occupants = [recipient.id, sender.id]
        let createChatBlock: (QBUUser) -> Void = { user in
            let dialog = QBChatDialog(dialogID: nil, type: .private)
            dialog.occupantIDs = occupants.filter({ ($0 ?? 0) != user.id }).map({ NSNumber(value: $0 ?? 0) })
            QBRequest.createDialog(dialog) { [weak self] (response, dialog) in
                LogUtils.info(dialog)
                self?.dialog = dialog
                completion(.success((dialog, user.id)))
            } errorBlock: { (response) in
                LogUtils.error(response)
                completion(.failure(.other(error: response.error?.error)))
            }
        }
        
        let connectChatBlock: (QBUUser) -> Void = { user in
            guard !QBChat.instance.isConnected else {
                createChatBlock(user)
                return
            }
            QBChat.instance.connect(withUserID: user.id, password: user.password!) { (error) in
                if let error = error {
                    LogUtils.error(error)
                    completion(.failure(.other(error: error)))
                }
                else {
                    createChatBlock(user)
                }
            }
        }
        
        guard let token = self.tokenGetter() else {
            completion(.failure(.unauthorized))
            return
        }
        
        connectQB(token: token) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                connectChatBlock(user)
            case .failure(_):
                self.tokenRefresher {
                    guard let token = self.tokenGetter() else {
                        completion(.failure(.unauthorized))
                        return
                    }
                    self.connectQB(token: token) { (result) in
                        switch result {
                        case .success(let user):
                            connectChatBlock(user)
                        case .failure(let error):
                            completion(.failure(.other(error: error)))
                        }
                    }
                }
            }
        }
    }
    
    public func getChatUserId(_ completion: @escaping (Result<UInt, TelemedError>) -> Void) {
        if let userId = QBSession.current.sessionDetails?.userID {
            completion(.success(userId))
            return
        }
        guard let token = self.tokenGetter() else {
            completion(.failure(.unauthorized))
            return
        }
        connectQB(token: token) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                completion(.success(user.id))
            case .failure(_):
                self.tokenRefresher {
                    guard let token = self.tokenGetter() else {
                        completion(.failure(.unauthorized))
                        return
                    }
                    self.connectQB(token: token) { (result) in
                        switch result {
                        case .success(let user):
                            completion(.success(user.id))
                        case .failure(let error):
                            completion(.failure(.other(error: error)))
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: - Public methods
public extension TelemedChatManager {
    
}

// MARK: - Private methods
private extension TelemedChatManager {
    
    private func configureQuickBlox(config: QuickBloxConfig) {
        QBSettings.applicationID = config.applicationId
        QBSettings.authKey = config.authKey
        QBSettings.authSecret = config.authSecret
        QBSettings.accountKey = config.accountKey
        QBSettings.apiEndpoint = config.api
        QBSettings.chatEndpoint = config.chatApi
        QBSettings.autoReconnectEnabled = true
        QBSettings.carbonsEnabled = true
        QBRTCConfig.setAnswerTimeInterval(45)
        
		#if DEBUG

		QBSettings.logLevel = .debug
		QBSettings.enableXMPPLogging()
		#endif
        QBRTCClient.initializeRTC()
    }
    
    // MARK: connectQB
    private func connectQB(token: String, completion: @escaping (Swift.Result<QBUUser, Error>) -> Void) {
        
        let login = ""  // TODO: - Remove bogus
        
        QBRequest.logIn(withUserLogin: login, password: token) { (response, user) in
            if let session = QBSession.current.sessionDetails?.token {
                user.password = session
                completion(.success(user))
            }
            else {
                completion(.failure(NSError()))
            }
            
        } errorBlock: { (response) in
            LogUtils.error(response)
            if let error = response.error?.error {
                completion(.failure(error))
            }
            else {
                completion(.failure(NSError()))
            }
        }
    }
    
}
