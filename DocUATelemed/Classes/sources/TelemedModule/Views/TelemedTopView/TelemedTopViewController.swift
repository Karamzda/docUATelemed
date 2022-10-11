//
//  TelemedTopViewController.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 04.10.2022.
//

import Foundation

protocol TelemedTopViewControllerDelegate: AnyObject {
    func callButtonTapped()
    func videoButtonTapped()
    func finishCosultationTapped()
    func timerFinished()
}

protocol TelemedTopViewControllerProtocol: AnyObject {
    func set(data: TelemedTopViewData)
    func callButtonTapped()
    func videoButtonTapped()
    func finishCosultationTapped()
}

class TelemedTopViewController: TelemedTopViewControllerProtocol {
    
    weak var view: TelemedTopViewProtocol!
    weak var delegate: TelemedTopViewControllerDelegate?
    
    private var data: TelemedTopViewData!
    
    private var timer: Timer?
    private var endTimeInterval: TimeInterval = 0
    
    init(view: TelemedTopViewProtocol!) {
        self.view = view
    }
    
    func set(data: TelemedTopViewData) {
        self.data = data
        startTimer()
    }
    
    private func startTimer() {
        let startDate = Date()
        endTimeInterval = data.endDate.timeIntervalSinceNow - startDate.timeIntervalSinceNow
        updateTime(timeInterval: endTimeInterval)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.endTimeInterval -= 1
            if self.endTimeInterval < 0 {
                timer.invalidate()
                self.delegate?.timerFinished()
            } else {
                self.updateTime(timeInterval: self.endTimeInterval)
            }
        })
    }
    
    private func updateTime(timeInterval: TimeInterval) {
        let components = DateComponents(minute: Int(self.endTimeInterval) / 60, second: Int(self.endTimeInterval) % 60)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.maximumUnitCount = 0
        
        if self.endTimeInterval < (5 * 60) {
            self.view.setTimeLeft(value: (formatter.string(from: components) ?? ""), color: .red)
        } else {
            self.view.setTimeLeft(value: (formatter.string(from: components) ?? ""), color: TelemedColors.darkGrey.uiColor)
        }
    }
    
    func callButtonTapped() {
        delegate?.callButtonTapped()
    }
    
    func videoButtonTapped() {
        delegate?.videoButtonTapped()
    }
    
    func finishCosultationTapped() {
        delegate?.finishCosultationTapped()
    }
}
