//
//  LogUtils.swift
//  DocUATelemed
//
//  Created by Taras Zinchenko on 09.10.2022.
//


import Foundation

enum PrintType: String {
    case info = "💬"
    case success = "✅"
    case warn = "⚠️"
    case error = "❌"
}

final class LogUtils {
    
    static var printLog = true
    
    static func info(_ message: Any..., filePath: String = #file, funcName: String = #function) {
        customPrint(message, type: .info, filePath: filePath, funcName: funcName)
    }
    
    static func success(_ message: Any..., filePath: String = #file, funcName: String = #function) {
        customPrint(message, type: .success, filePath: filePath, funcName: funcName)
    }
    
    static func warn(_ message: Any..., filePath: String = #file, funcName: String = #function) {
        customPrint(message, type: .warn, filePath: filePath, funcName: funcName)
    }
    
    static func error(_ message: Any..., filePath: String = #file, funcName: String = #function) {
        customPrint(message, type: .error, filePath: filePath, funcName: funcName)
    }
    
    private static func customPrint(_ message: Any..., type: PrintType, filePath: String, funcName: String) {
        guard printLog else {
            return
        }
        
        DebugUtil.run {
            let fileName = filePath.components(separatedBy: "/").last?.components(separatedBy: ".")
                .first ?? "unkonwn_file_name"
            //#if DEBUG
            print("\n\(type.rawValue) \(fileName).\(funcName) \(message)\n")
            //#else
            //#endif
        }
    }
}

final class DebugUtil {
    /// Use this method for run your code on debug or prod
    ///
    /// - Parameters:
    ///   - handler: this block will be run on debug only
    ///   - elseHandler: this block will be run on prod only
    class func run(_ handler: @escaping () -> Void, else elseHandler: (() -> Void)) {
        #if DEBUG
        handler()
        #else
        elseHandler()
        #endif
    }
    
    /// Use this method for run your code on debug
    ///
    /// - Parameter handler: this block will be run on debug only
    class func run(_ handler: @escaping () -> Void) {
        #if DEBUG
        handler()
        #endif
    }
}
