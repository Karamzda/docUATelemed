//
//  PhotoAttaching.swift
//  ChatLayout
//
//  Created by Taras Zinchenko on 09.10.2022.
//

import UIKit
import Photos

protocol PhotoAttaching {
    var imagePickerController: UIImagePickerController { get set }
    func chooseIcloud()
    func takePhoto()
    func choosePhoto()
    func dismissAttachment()
    func showPhotoAttachingOptions()
}

extension PhotoAttaching where Self: UIViewController {
    
    func takePhoto() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { isGranted in
            DispatchQueue.main.async {
                if isGranted && UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePickerController.sourceType = .camera
                    self.imagePickerController.cameraDevice = .front
                    self.present(self.imagePickerController, animated: true, completion: nil)
                } else {
                    self.showAccessDeniedAlertController(
                        with: "camera_access_denied_alert_title".localized,
                        message: "camera_access_denied_alert_message".localized
                    )
                }
            }
        })
    }
    
    func choosePhoto() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.imagePickerController.sourceType = .photoLibrary
                    self.imagePickerController.allowsEditing = true
                    self.present(self.imagePickerController, animated: true, completion: nil)
                default:
                    self.showAccessDeniedAlertController(
                        with: "photo_library_access_denied_alert_title".localized,
                        message: "photo_library_access_denied_alert_message".localized
                    )
                }
            }
        }
    }
    
    
    func showPhotoAttachingOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let take = UIAlertAction(title: "general_take_a_new_photo".localized, style: .default) { _ in
            self.takePhoto()
        }
        let choose = UIAlertAction(title: "general_choose_from_gallery".localized, style: .default) { _ in
            self.choosePhoto()
        }
        
        let chooseIcloud = UIAlertAction(title: "general_choose_from_icloud".localized, style: .default) { _ in
            self.chooseIcloud()
        }
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel){
            _ in
            self.dismissAttachment()
        }
        alert.addAction(take)
        alert.addAction(choose)
        alert.addAction(chooseIcloud)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showAccessDeniedAlertController(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settings = UIAlertAction(title: "general_settings".localized, style: .default) { _ in
            let application = UIApplication.shared
            if let url = URL(string: UIApplication.openSettingsURLString), application.canOpenURL(url) {
                application.open(url)
            }
        }
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        alert.addAction(settings)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
