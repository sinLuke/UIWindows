//
//  UIWindowBarView.swift
//  UIWindows
//
//  Created by Luke Yin on 2019-12-02.
//  Copyright © 2019 sinLuke. All rights reserved.
//

import UIKit

class UIWindowBarView: UIView {
    let gradient = CAGradientLayer()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        addGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addGradient(){
        

        gradient.frame = self.bounds
        gradient.colors = [UIColor.init(displayP3Red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0), UIColor.init(displayP3Red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)]

        self.layer.insertSublayer(gradient, at: 0)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = self.bounds
    }

}
