//
//  UIView+ReturnAnchors.swift
//  elta-ios
//
//  Created by y.lvov on 1/23/19.
//  Copyright © 2019 nullgr. All rights reserved.
//

import UIKit

extension UIView {
    func _anchorTop(_ top: NSLayoutYAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = topAnchor.constraint(greaterThanOrEqualTo: top, constant: constant)
        case .lessThanOrEqual:
            anchor = topAnchor.constraint(lessThanOrEqualTo: top, constant: constant)
        default:
            anchor = topAnchor.constraint(equalTo: top, constant: constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorBottom(_ bottom: NSLayoutYAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = bottomAnchor.constraint(lessThanOrEqualTo: bottom, constant: -constant)
        case .lessThanOrEqual:
            anchor = bottomAnchor.constraint(greaterThanOrEqualTo: bottom, constant: -constant)
        default:
            anchor = bottomAnchor.constraint(equalTo: bottom, constant: -constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorLeft(_ left: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = leftAnchor.constraint(greaterThanOrEqualTo: left, constant: constant)
        case .lessThanOrEqual:
            anchor = leftAnchor.constraint(lessThanOrEqualTo: left, constant: constant)
        default:
            anchor = leftAnchor.constraint(equalTo: left, constant: constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorLeading(_ left: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = leadingAnchor.constraint(greaterThanOrEqualTo: left, constant: constant)
        case .lessThanOrEqual:
            anchor = leadingAnchor.constraint(lessThanOrEqualTo: left, constant: constant)
        default:
            anchor = leadingAnchor.constraint(equalTo: left, constant: constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorRight(_ right: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = rightAnchor.constraint(lessThanOrEqualTo: right, constant: -constant)
        case .lessThanOrEqual:
            anchor = rightAnchor.constraint(greaterThanOrEqualTo: right, constant: -constant)
        default:
            anchor = rightAnchor.constraint(equalTo: right, constant: -constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorTrailing(_ right: NSLayoutXAxisAnchor, _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = trailingAnchor.constraint(lessThanOrEqualTo: right, constant: -constant)
        case .lessThanOrEqual:
            anchor = trailingAnchor.constraint(greaterThanOrEqualTo: right, constant: -constant)
        default:
            anchor = trailingAnchor.constraint(equalTo: right, constant: -constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorWidth(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
        case .lessThanOrEqual:
            anchor = widthAnchor.constraint(lessThanOrEqualToConstant: constant)
        default:
            anchor = widthAnchor.constraint(equalToConstant: constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorHeight(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
        case .lessThanOrEqual:
            anchor = heightAnchor.constraint(lessThanOrEqualToConstant: constant)
        default:
            anchor = heightAnchor.constraint(equalToConstant: constant)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorHeightEqual(_ height: NSLayoutDimension, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = heightAnchor.constraint(greaterThanOrEqualTo: height, multiplier: multiplier)
        case .lessThanOrEqual:
            anchor = heightAnchor.constraint(lessThanOrEqualTo: height, multiplier: multiplier)
        default:
            anchor = heightAnchor.constraint(equalTo: height, multiplier: multiplier)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
    
    func _anchorWidthEqual(_ width: NSLayoutDimension, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchor: NSLayoutConstraint
        switch relation {
        case .greaterThanOrEqual:
            anchor = widthAnchor.constraint(greaterThanOrEqualTo: width, multiplier: multiplier)
        case .lessThanOrEqual:
            anchor = widthAnchor.constraint(lessThanOrEqualTo: width, multiplier: multiplier)
        default:
            anchor = widthAnchor.constraint(equalTo: width, multiplier: multiplier)
        }
        
        anchor.priority = priority
        anchor.isActive = true
        return anchor
    }
}
