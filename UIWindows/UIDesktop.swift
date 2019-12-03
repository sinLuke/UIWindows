//
//  WindowsContainerViewController.swift
//  iOSWindow
//
//  Created by Luke on 2019-07-28.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

@objc public protocol UIDesktopDelegate {
    @objc optional func destop(desktop: UIDesktop, shouldClose window: UIWindowsWindow) -> Bool
    @objc optional func destop(desktop: UIDesktop, didClose window: UIWindowsWindow)
    @objc optional func destop(desktop: UIDesktop, shouldFocusOn window: UIWindowsWindow) -> Bool
    @objc optional func destop(desktop: UIDesktop, didFocusOn window: UIWindowsWindow)
    @objc optional func destop(desktop: UIDesktop, shouldRemoveFocusOn window: UIWindowsWindow) -> Bool
    @objc optional func destop(desktop: UIDesktop, didRemoveFocusOn window: UIWindowsWindow)
    @objc optional func destop(desktop: UIDesktop, didAdd window: UIWindowsWindow)
}

@objc public class UIDesktop: NSObject {

    weak var view: UIView?
    weak var parentVC: UIViewController?
    private var windows: [UIWindowsWindow] = []
    public var delegate: UIDesktopDelegate?
    
    public init(makeViewControllerAsDesktop viewController: UIViewController) {
        self.parentVC = viewController
        self.view = viewController.view
    }
    
    public func getNumOfWindow() -> Int {
        return windows.count
    }
    
    public func getWindow(at index: Int) -> UIWindowsWindow {
        return windows[index % windows.count]
    }
    
    public func closeAllWindows(){
        for w in windows {
            if delegate?.destop?(desktop: self, shouldClose: w) ?? true {
                w.closeWindow()
                delegate?.destop?(desktop: self, didClose: w)
            }
        }
    }
    
    public func set(focus window: UIWindowsWindow) {
        if windows.contains(window) {
            for w in windows {
                if w == window {
                    if delegate?.destop?(desktop: self, shouldFocusOn: w) ?? true {
                        w.set(focus: true)
                        delegate?.destop?(desktop: self, didFocusOn: w)
                        return
                    }
                    
                } else {
                    if w.isFocused {
                        if delegate?.destop?(desktop: self, shouldRemoveFocusOn: w) ?? true {
                            w.set(focus: false)
                            delegate?.destop?(desktop: self, didRemoveFocusOn: w)
                        } else {
                            return
                        }
                    }
                }
            }
        }
    }
    
    public func remove(window: UIWindowsWindow) {
        for i in 0..<self.windows.count {
            if i < self.windows.count, self.windows[i] == window {
                if delegate?.destop?(desktop: self, shouldClose: self.windows[i]) ?? true {
                    let w = self.windows.remove(at: i)
                    w.removeFromSuperview()
                    w.childVC.navigationController?.removeFromParent()
                    delegate?.destop?(desktop: self, didClose: w)
                }
                
            }
        }
        if windows.count >= 1 {
            self.set(focus: windows[windows.count - 1])
        }
    }
    
    public func add(new window: UIWindowsWindow) {

        guard let view = self.view else {
            return
        }
        
        guard !windows.contains(window) else {
            return
        }
         
        windows.append(window)
        
        view.addSubview(window)
        parentVC?.addChild(window.childVC)
        window.parentVC = parentVC
        window.desktop = self
        window.translatesAutoresizingMaskIntoConstraints = false

        window.topGap = window.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top + CGFloat(10*self.windows.count))
        window.leftGap = window.leftAnchor.constraint(equalTo: view.leftAnchor, constant: CGFloat(10*self.windows.count))
        window.heightConstant = window.heightAnchor.constraint(equalToConstant: 400)
        window.widthConstant = window.widthAnchor.constraint(equalToConstant: 300)

        let fullScreen = false

        window.topGap.isActive = !fullScreen
        window.leftGap.isActive = !fullScreen
        window.heightConstant.isActive = !fullScreen
        window.widthConstant.isActive = !fullScreen
        
        view.layoutSubviews()

        window.backupPosition()
        self.set(focus: window)
        
        delegate?.destop?(desktop: self, didAdd: window)
    }
    
    func handlePan(changed window:UIWindowsWindow, offsetX: CGFloat, offsetY: CGFloat) {
        window.transformWindows(transform: offsetX, y: offsetY)
    }
    
    func handlePan(end window:UIWindowsWindow, offsetX: CGFloat, offsetY: CGFloat) {
        
        guard let view = self.view else {
            return
        }
        
        var topGapConstant = window.topGap.constant + offsetY
        let leftGapConstant = window.leftGap.constant + offsetX
        
        if topGapConstant < view.safeAreaInsets.top {
            topGapConstant = view.safeAreaInsets.top
        }
        
        let maxHeight = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - window.config.barHeight
        
        if topGapConstant > maxHeight {
            topGapConstant = maxHeight
        }
        
        window.set(constraint: topGapConstant, left: leftGapConstant, superView: view)
    }
}
