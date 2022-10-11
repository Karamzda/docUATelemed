//
//  TelemedViewController.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 04.10.2022.
//

import UIKit


open class TelemedViewController: UIViewController {
    public var type: TelemedConfigurationType = .doctor
    private (set) var presenter: TelemedPresenter = TelemedPresenter()
    public var recipient: TelemedChatUser!
    public var sender: TelemedChatUser!
    
    private var chatViewController: ChatViewController?
    
    private lazy var topView: TelemedTopView = {
        let view = TelemedTopView(configuration: TelemedTopViewConfiguration(type: type))
        return view
    }()
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        presenter.view = self
        
        super.viewDidLoad()
        setupUI()
        presenter.viewHasLoaded()
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewHasAppeared()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewHasDissapeared()
    }
    
    private func setupUI() {
        view.addSubview(topView)
        let data = TelemedTopViewData(endDate: Date().addingTimeInterval(60), userName: "Зінченко Тарас Васильович,Зінченко Тарас Васильович,Зінченко Тарас Васильович,Зінченко Тарас Васильович,")
        topView.set(model: data)
        setupAnchors()
    }
    
    private func setupAnchors() {
        topView
            .anchorTop(view.safeAreaLayoutGuide.topAnchor, 0)
            .anchorLeft(view.leftAnchor, 0)
            .anchorRight(view.rightAnchor, 0)
            .anchorHeight(112)
    }
    
    func setupChat(viewController: ChatViewController) {
        chatViewController = viewController
        
    }
}
