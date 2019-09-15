//
//  UIView_extension.swift
//  iOSWindow
//
//  Created by Luke on 2019-07-28.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

enum LayoutStyle {
    case fixLeading(leading: CGFloat, intrinsic: CGFloat)
    case fixTrailing(trailing: CGFloat, intrinsic: CGFloat)
    case fill(leading: CGFloat, trailing: CGFloat)
}

func fixInto(this: UIView, view: UIView, horizontal: LayoutStyle, vertical: LayoutStyle) {
    
    this.translatesAutoresizingMaskIntoConstraints = false
    
    switch horizontal {
    case .fill(leading: let left, trailing: let right):
        this.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive = true
        this.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive = true
    case .fixLeading(leading: let left, intrinsic: let width):
        this.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive = true
        this.widthAnchor.constraint(equalToConstant: width).isActive = true
    case .fixTrailing(trailing: let right, intrinsic: let width):
        this.widthAnchor.constraint(equalToConstant: width).isActive = true
        this.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive = true
    }
    
    switch vertical {
    case .fill(leading: let top, trailing: let bottom):
        this.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        this.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    case .fixLeading(leading: let top, intrinsic: let height):
        this.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        this.heightAnchor.constraint(equalToConstant: height).isActive = true
    case .fixTrailing(trailing: let bottom, intrinsic: let height):
        this.heightAnchor.constraint(equalToConstant: height).isActive = true
        this.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    }
}

class UIWindowView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
