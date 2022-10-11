//
//  ChatPermissionController.swift
//  DocUAChat
//
//  Created by severehed on 01.04.2021.
//

import UIKit

class ChatPermissionController: UIViewController {

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var permission: Permissions?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftButton.layer.cornerRadius = 16
        self.rightButton.layer.cornerRadius = 16
        self.containerView.layer.cornerRadius = 16
    }
    
    override func loadView() {
        super.loadView()
        if TelemedChatManager.appearance == .doctor {
            self.leftButton.layer.cornerRadius = 4
            self.leftButton.layer.borderWidth = 1
            self.leftButton.layer.borderColor = TelemedColors.greenyBlue.uiColor.cgColor
            self.leftButton.setTitleColor(TelemedColors.greenyBlue.uiColor, for: .normal)
            
            self.rightButton.layer.cornerRadius = 4
            self.rightButton.backgroundColor = TelemedColors.greenyBlue.uiColor
            self.rightButton.setTitleColor(.white, for: .normal)
            self.closeButton.setImage(ImagesHelper.loadImage(name: "doc_ic_close_permission"), for: .normal)
        }
    }
    
    public func buildPermission(_ permission: Permissions) {
        self.permission = permission
        switch permission {
        case .galleryButton:
            self.buildGalleryPermission()
        }
    }
    
    private func buildGalleryPermission() {
        self.titleLabel.text = "permission_send_file_title".localized
        self.descLabel.text = "permission_send_file_subtitle".localized
        self.leftButton.setTitle("permission_send_file_galery".localized, for: .normal)
        self.rightButton.setTitle("permission_send_file_camera".localized, for: .normal)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
    }
    @IBAction func leftButton(_ sender: Any) {
    }
    @IBAction func rightButton(_ sender: Any) {
    }
}

public enum Permissions {
    case galleryButton
}
////permissions text
//"permission_send_file_title" = "Прикріпити файл"
//"permission_send_file_subtitle" = "Оберіть, як хотіли би прикріпити файл"
//"permission_send_file_galery" = "Галерея"
//"permission_send_file_camera" = "Камера"
//
//"permission_promo_title" = "Уведіть промокод"
//"permission_promo_decline" = "Скасувати"
//"permission_promo_accept" = "Застосувати"
//
//"permission_notification_accept" = "Дозволити"
//"permission_notification_title" = "Дозволити сповіщення?"
//"permission_notification_subtitle" = "Повідомлення від лікаря, сформовані рекомендації та унікальні пропозиції в додатку"
//"permission_notification_decline" = "Скасувати"
//
//"permission_doctor_decline_title" = "Лікар відхилив запит"
//"permission_doctor_decline_subtitle" = "Извините, врач отклонил заявку, ваши деньги сейчас вернуться на Ваш счет. Желаете выбрать другого врача?"
//"permission_doctor_decline_accept" = "Вибрати лікаря"
//"permission_doctor_decline_decline" = "Ні, дякую"
//
//"permission_camera_title" = "Дозволити доступ до камери?"
//"permission_camera_subtitle" = "Дозвіл потрібен, щоб ви могли спілкуватися з лікарем у форматі відеодзвінку"
//"permission_camera_decline" = "Скасувати"
//"permission_camera_accept" = "Дозволити"
//
//"permission_micro_title" = "Дозволити доступ до мікрофону?"
//"permission_micro_subtitle" = "Дозвіл потрібен, щоб ви могли спілкуватися з лікарем форматі аудіодзвінку"
//"permission_micro_decline" = "Скасувати"
//"permission_micro_accept" = "Дозволити"
//
//"permission_galery_title" = "Доступ до галереї?"
//"permission_galery_subtitle" = "Доступ до галереї потрібен щоб Ви могли відправити лікарю файли під час консультації."
//"permission_galery_decline" = "Скасувати"
//"permission_galery_accept" = "Дозволити"
//
//"permission_patient_decline_title" = "Завершити консультацію?"
//"permission_patient_decline_subtitle" = "Ви не зможете продовжити цю консультацію з лікарем "
//"permission_patient_decline_decline" = "Ні, продовжити"
//"permission_patient_decline_accept" = "Так, завершити"
