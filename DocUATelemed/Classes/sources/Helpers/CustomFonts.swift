//
//  Fonts.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 09.10.2022.
//

import Foundation

import CoreText

public class CustomFonts: NSObject {
    
    public enum Style: CaseIterable {
        case suisseIntlBold
        case suisseIntlBook
        case suisseIntlLight
        case suisseIntlMedium
        case suisseIntlRegular
        case suisseIntlSemiBold
        public var value: String {
            switch self {
            case .suisseIntlBold: return "SuisseIntl-Bold"
            case .suisseIntlBook: return "SuisseIntl-Book"
            case .suisseIntlLight: return "SuisseIntl-Light"
            case .suisseIntlMedium: return "SuisseIntl-Medium"
            case .suisseIntlRegular: return "SuisseIntl-Regular"
            case .suisseIntlSemiBold: return "SuisseIntl-SemiBold"
            }
        }
        
        public func font(size: CGFloat) -> UIFont? {
            return UIFont(name: self.value, size: size) ?? UIFont.init()
        }
    }
    
    // Lazy var instead of method so it's only ever called once per app session.
    public static func loadFonts() {
        let fontNames = Style.allCases.map { $0.value }
        for fontName in fontNames {
            loadFont(withName: fontName)
        }
    }
    
    private static func loadFont(withName fontName: String) {
        guard
            let bundleURL = Bundle(for: self).url(forResource: "DocUATelemed", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL),
            let fontURL = bundle.url(forResource: fontName, withExtension: "otf"),
            let fontData = try? Data(contentsOf: fontURL) as CFData,
            let provider = CGDataProvider(data: fontData),
            let font = CGFont(provider) else {
            return
        }
        CTFontManagerRegisterGraphicsFont(font, nil)
    }
    
}
