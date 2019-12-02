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
    
    var config = UIWindowsConfig.defaultConfig
    
    let closeButton = { () -> UIButton in
        
        let redBorder = UIColor.init(displayP3Red: 226/255, green: 73/255, blue: 64/255, alpha: 1.0)
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
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
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
        
    }

    override public func draw(_ rect: CGRect) {
        
        self.backgroundColor = UIColor.init(displayP3Red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0)
        
        fix(this: closeButton, into: self, horizontal: .fixLeading(leading: 12, intrinsic: 18), vertical: .fixLeading(leading: (config.barHeight - 18)/2, intrinsic: 18))
        fix(this: fullScreenButton, into: self, horizontal: .fixLeading(leading: 42, intrinsic: 18), vertical: .fixLeading(leading: (config.barHeight - 18)/2, intrinsic: 18))
    }
    
    @objc func closeWindow(_ sander: UIButton) {
        windowDelegate?.closeWindow()
    }
    
    @objc func fullscreen(_ sander: UIButton) {
        windowDelegate?.enterfullscreen()
    }
}
