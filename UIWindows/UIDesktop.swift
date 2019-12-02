//
//  WindowsContainerViewController.swift
//  iOSWindow
//
//  Created by Luke on 2019-07-28.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

protocol UIDesktopDelegate {
    func getNumOfWindow() -> Int
    func getWindow(at index: Int) -> UIWindowsWindow
    func set(focus window: UIWindowsWindow)
}

public class UIDesktop: UIDesktopDelegate {

    weak var view: UIView?
    weak var parentVC: UIViewController?
    private var windows: [UIWindowsWindow] = []
    
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
            w.closeWindow()
        }
    }
    
    public func set(focus window: UIWindowsWindow) {
        if windows.contains(window) {
            for w in windows {
                if w == window {
                    w.set(focus: true)
                } else {
                    w.set(focus: false)
                }
            }
        }
    }
    
    public func remove(window: UIWindowsWindow) {
        for i in 0..<self.windows.count {
            if i < self.windows.count, self.windows[i] == window {
                self.windows.remove(at: i)
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
        parentVC?.addChild(window.navigationVC)
        window.parentVC = parentVC
        window.desktop = self
        window.translatesAutoresizingMaskIntoConstraints = false

        window.topGap = window.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top + CGFloat(10*self.windows.count))
        window.leftGap = window.leftAnchor.constraint(equalTo: view.leftAnchor, constant: CGFloat(10*self.windows.count))
        window.heightConstant = window.heightAnchor.constraint(equalToConstant: 400)
        window.widthConstant = window.widthAnchor.constraint(equalToConstant: 300)

        window.fullTop = window.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        window.fullBottom = window.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        window.fullLeft = window.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        window.fullRight = window.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)

        let fullScreen = false

        window.topGap.isActive = !fullScreen
        window.leftGap.isActive = !fullScreen
        window.heightConstant.isActive = !fullScreen
        window.widthConstant.isActive = !fullScreen

        window.fullTop.isActive = fullScreen
        window.fullBottom.isActive = fullScreen
        window.fullLeft.isActive = fullScreen
        window.fullRight.isActive = fullScreen

        view.layoutSubviews()

        self.set(focus: window)
    }
    
    func handlePan(changed window:UIWindowsWindow, offsetX: CGFloat, offsetY: CGFloat) {
        window.transformWindows(transform: offsetX, y: offsetY)
    }
    
    func handlePan(end window:UIWindowsWindow, offsetX: CGFloat, offsetY: CGFloat) {
        
        print(offsetY)
        
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
