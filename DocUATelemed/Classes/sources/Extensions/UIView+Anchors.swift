//
//  UIView+Anchors.swift
//  One Touch
//
//  Created by mac on 01.03.18.
//  Copyright © 2018 Yaroslav Lvov. All rights reserved.
//

import UIKit
import Foundation

typealias ViewAnchors = (top: NSLayoutConstraint?, left: NSLayoutConstraint?, bottom: NSLayoutConstraint?, right: NSLayoutConstraint?, width: NSLayoutConstraint?, height: NSLayoutConstraint?)

extension UIView {
    public func fillSuperview(padding: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            self
                .anchorLeft(superview.leftAnchor, padding)
                .anchorRight(superview.rightAnchor, padding)
                .anchorTop(superview.topAnchor, padding)
                .anchorBottom(superview.bottomAnchor, padding)
        }
    }
    
    @discardableResult
    func anchorCenterXSuperview(_ constant: CGFloat = 0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
        return self
    }
    
    @discardableResult
    func anchorCenterXToView(_ view: UIView, constant: CGFloat = 0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        let anchor = view.centerXAnchor
        centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func anchorCenterYToView(_ view: UIView, constant: CGFloat = 0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        let anchor = view.centerYAnchor
        centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func anchorCenterYSuperview(_ constant: CGFloat = 0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
        return self
    }
    
    @discardableResult
    func anchorCenterToSuperview() -> UIView {
        anchorCenterXSuperview()
        anchorCenterYSuperview()
        return self
    }
    
    @discardableResult
    func anchorTop(_ top: NSLayoutYAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorTop(top, constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorBottom(_ bottom: NSLayoutYAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorBottom(bottom, constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorLeft(_ left: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorLeft(left, constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorLeading(_ left: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorLeading(left, constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorRight(_ right: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorRight(right, constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorTrailing(_ left: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorTrailing(left, constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorWidth(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorWidth(constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorHeight(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorHeight(constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorWidthAndHeight(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> UIView {
        _ = _anchorWidth(constant, relation: relation, priority: priority)
        _ = _anchorHeight(constant, relation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func anchorEqualWidth(_ width: NSLayoutDimension, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required, multiplier: CGFloat = 1.0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        _ = _anchorWidthEqual(width, relation: relation, priority: priority, multiplier: multiplier)
        return self
    }
    
    @discardableResult
    func anchorEqualHeight(_ height: NSLayoutDimension, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required, multiplier: CGFloat = 1.0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        _ = _anchorHeightEqual(height, relation: relation, priority: priority, multiplier: multiplier)
        return self
    }
    
    @discardableResult
    func anchorEqualHeight(_ height: NSLayoutDimension, constant: CGFloat, multiplier: CGFloat = 1.0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalTo: height, multiplier: multiplier, constant: constant).isActive = true
        
        return self
    }
    
    @discardableResult
    func anchorEqualHeight(_ height: NSLayoutDimension, _ constant: CGFloat, priority: UILayoutPriority = .required) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        
        let anchor = heightAnchor.constraint(equalTo: height, multiplier: 1.0, constant: constant)
        anchor.priority = priority
        anchor.isActive = true
        return self
    }
}
