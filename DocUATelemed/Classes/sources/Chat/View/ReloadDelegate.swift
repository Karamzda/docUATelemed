//
// ChatLayout
// ReloadDelegate.swift
//

import Foundation

public protocol ReloadDelegate: AnyObject {

    func reloadMessage(with id: String)
    
    func openAttach(url: URL,id:String)
    
    func saveFile(url: URL, name: String)

}
