//
//  ImagesHelper.swift
//  ChatLayout
//
//  Created by Taras Zinchenko on 05.10.2022.
//

import UIKit

public class ImagesHelper {
    private static var podsBundle: Bundle? {
        
        
        let bundle = Bundle(identifier: "DocUATelemed")
        return bundle
    }
    
    
    public static func loadImage(resolvedName: String) -> UIImage? {
        let name = "\(Appearence.assetPrefix)_\(resolvedName)"
        return loadImage(name: name)
    }
    
    public static func loadImage(name: String) -> UIImage? {
        let podBundle = Bundle(for: ImagesHelper.self)
        if let url = podBundle.url(forResource: "DocUATelemed", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: name, in: bundle, compatibleWith: nil)
        }
        return nil
    }

}
