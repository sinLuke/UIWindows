//
//  UIWindowBarView.swift
//  UIWindows
//
//  Created by Luke Yin on 2019-12-02.
//  Copyright © 2019 sinLuke. All rights reserved.
//

import UIKit

class UIWindowBarView: UIView {
    
    private let gradient : CAGradientLayer = CAGradientLayer()
    private let gradientStartColor = UIColor.init(displayP3Red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0)
    private let gradientEndColor = UIColor.init(displayP3Red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = self.bounds
    }

    override public func draw(_ rect: CGRect) {
        gradient.frame = self.bounds
        gradient.colors = [gradientEndColor.cgColor, gradientStartColor.cgColor]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0.2, y: 1)
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
    }
}
