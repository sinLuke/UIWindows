//
//  UIWindowsConfig.swift
//  UIWindows
//
//  Created by Luke Yin on 2019-12-02.
//  Copyright © 2019 sinLuke. All rights reserved.
//

import UIKit

public struct UIWindowsConfig {
    
    static var defaultConfig = UIWindowsConfig(minHeight: 300.0, minWidth: 200.0, tintColor: .systemBlue, cornerAdjustRadius: 20.0)
    
    let minHeight: CGFloat
    let minWidth: CGFloat
    let tintColor: UIColor
    let cornerAdjustRadius: CGFloat
}
