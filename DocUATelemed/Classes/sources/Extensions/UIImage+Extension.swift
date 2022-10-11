//
//  UIImage+Extension.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 09.10.2022.
//

import UIKit

extension UIImage {
    func alpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIImage {
    
    enum CompressQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case hight = 0.75
        case highest = 1.0
    }
    
    func compressed(with quality: CompressQuality) -> UIImage? {
        guard let imageData = self.jpegData(compressionQuality: quality.rawValue) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

extension UIImage {
    
    func scalled(scaleFactor: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        return scalled(to: newSize)
    }
    
    func scalled(to targetSize: CGSize) -> UIImage? {
        guard size.width != 0, size.height != 0 else {
            return nil
        }
        
        defer { UIGraphicsEndImageContext() }
        let newSize: CGSize
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
