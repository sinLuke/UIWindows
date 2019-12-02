//
//  UIWindowBarView.swift
//  UIWindows
//
//  Created by Luke Yin on 2019-12-02.
//  Copyright © 2019 sinLuke. All rights reserved.
//

import UIKit

class UIWindowBarView: UIView {
    
    var windowDelegate: UIWindowsDelegate?
    
    private let gradient : CAGradientLayer = CAGradientLayer()
    private let gradientEndColor = UIColor.init(displayP3Red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0)
    private let gradientStartColor = UIColor.init(displayP3Red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    
    let closeButton = { () -> UIButton in
        
        let redBorder = UIColor.init(displayP3Red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
        let redFill = UIColor.init(displayP3Red: 255/255, green: 97/255, blue: 89/255, alpha: 1.0)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        button.layer.borderColor = redBorder.cgColor
        button.layer.borderWidth = 1/UIScreen.main.scale
        button.layer.cornerRadius = 6
        button.backgroundColor = redFill
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(closeWindow(_:)), for: .touchUpInside)
        
        return button
    }()
    
    let fullScreenButton = { () -> UIButton in
        
        let greenBorder = UIColor.init(displayP3Red: 40/255, green: 150/255, blue: 42/255, alpha: 1.0)
        let greenFill = UIColor.init(displayP3Red: 39/255, green: 200/255, blue: 65/255, alpha: 1.0)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        button.layer.borderColor = greenBorder.cgColor
        button.layer.borderWidth = 1/UIScreen.main.scale
        button.layer.cornerRadius = 6
        button.backgroundColor = greenFill
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(fullscreen(_:)), for: .touchUpInside)
        
        return button
    }()
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if closeButton.superview == nil {
            self.addSubview(closeButton)
        }
        
        if fullScreenButton.superview == nil {
            self.addSubview(fullScreenButton)
        }
        
        fix(this: closeButton, into: self, horizontal: .fixLeading(leading: 8, intrinsic: 12), vertical: .fixLeading(leading: 5, intrinsic: 12))
        fix(this: fullScreenButton, into: self, horizontal: .fixLeading(leading: 8, intrinsic: 12), vertical: .fixLeading(leading: 5, intrinsic: 12))
        gradient.frame = self.bounds
    }

    override public func draw(_ rect: CGRect) {
        gradient.frame = self.bounds
        gradient.colors = [gradientEndColor.cgColor, gradientStartColor.cgColor]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0.2, y: 1)
        
        self.clipsToBounds = true
        
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
    }
    
    @objc func closeWindow(_ sander: UIButton) {
        windowDelegate?.closeWindow()
    }
    
    @objc func fullscreen(_ sander: UIButton) {
        windowDelegate?.enterfullscreen()
    }
}
