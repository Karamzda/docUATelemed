//
//  ConnectionProblemController.swift
//  DocUA
//
//  Created by severehed on 30.03.2021.
//

import UIKit

class ConnectionProblemController: UIViewController {

    @IBOutlet weak var imageError: UIImageView!
    @IBOutlet weak var reconnectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reconnectButton.layer.cornerRadius = 16
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        if TelemedChatManager.appearance == .doctor {
            reconnectButton.layer.cornerRadius = 4
            reconnectButton.backgroundColor = TelemedColors.greenyBlue.uiColor
            reconnectButton.setTitleColor(.white, for: .normal)
            
            imageError.image = ImagesHelper.loadImage(resolvedName: "ic_reconnect")
        } else {
            reconnectButton.layer.cornerRadius = 16
            reconnectButton.backgroundColor = TelemedColors.main.uiColor
            reconnectButton.setTitleColor(.white, for: .normal)
            imageError.image = ImagesHelper.loadImage(resolvedName: "ic_reconnect")
        }
    }
    @IBAction func reconnectButtonTapped(_ sender: UIButton) {
    }

}
