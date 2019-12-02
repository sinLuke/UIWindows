//
//  DraggableView.swift
//  iOSWindow
//
//  Created by Luke on 2019-07-28.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

protocol UIWindowsDelegate {
    func closeWindow()
    func enterfullscreen()
    func exitfullscreen()
    func toggleFullScreen()
}

public class UIWindowsWindow: UIView {
    
    var config: UIWindowsConfig
    
    var topGap: NSLayoutConstraint!
    var leftGap: NSLayoutConstraint!
    var heightConstant: NSLayoutConstraint!
    var widthConstant: NSLayoutConstraint!
    
    var topGapBackup: CGFloat?
    var leftGapBackup: CGFloat?
    var heightConstantBackup: CGFloat?
    var widthConstantBackup: CGFloat?
    
    var oWidth: CGFloat = 0
    var oHeight: CGFloat = 0
    
    var oLeft: CGFloat = 0
    var oTop: CGFloat = 0
    
    var nWidth: CGFloat = 0
    var nHeight: CGFloat = 0
    
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    var leftTopView = UIView()
    var leftBotView = UIView()
    var rightTopView = UIView()
    var rightBotView = UIView()
    
    let containerView = UIView()
    let windowBarView = UIWindowBarView(frame: CGRect(x: 0, y: 0, width: 100, height: 22))
    var navigationVC = UIWindowsNavigationController()
    
    var childVC: UIViewController
    weak var parentVC: UIViewController?
    weak var desktop: UIDesktop?
    
    enum TouchEvent {
        case moveWindow
        case resize(left: Bool, top: Bool)
    }
    
    public init(childVC: UIViewController, with config: UIWindowsConfig?) {
        
        if let config = config {
            self.config = config
        } else {
            self.config = UIWindowsConfig.defaultConfig
        }
        
        self.childVC = childVC
            
        super.init(frame: CGRect(x: 10, y: 10, width: self.config.minWidth, height: self.config.minHeight))
        
        self.addSubview(containerView)
        self.backgroundColor = .clear
        containerView.addSubview(windowBarView)
        windowBarView.windowDelegate = self
        self.setUpCornerGestureView()

        fix(this: containerView, into: self, horizontal: .fill(leading: 0, trailing: 0), vertical: .fill(leading: 0, trailing: 0))
        
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 8
        containerView.layer.borderColor = UIColor.systemGray3.cgColor
        containerView.layer.borderWidth = 1/UIScreen.main.scale
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowRadius = 30
        self.layer.shadowOpacity = 0.5
        
        
        
        fix(this: windowBarView, into: self, horizontal: .fill(leading: 0, trailing: 0), vertical: .fixLeading(leading: 0, intrinsic: self.config.barHeight))
        
        if let childNVC = childVC as? UINavigationController {
            containerView.addSubview(childNVC.view)
            
            fix(this: childNVC.view, into: containerView, horizontal: .fill(leading: self.config.windowEdgeWidth, trailing: self.config.windowEdgeWidth), vertical: .fill(leading: self.config.barHeight, trailing: self.config.windowEdgeWidth))
            
        } else {
            navigationVC = UIWindowsNavigationController(rootViewController: childVC)
            containerView.addSubview(navigationVC.view)
            
            fix(this: navigationVC.view, into: containerView, horizontal: .fill(leading: self.config.windowEdgeWidth, trailing: self.config.windowEdgeWidth), vertical: .fill(leading: self.config.barHeight, trailing: self.config.windowEdgeWidth))
            
            navigationVC.windowDelegate = self
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))

        windowBarView.addGestureRecognizer(panGesture)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPreview() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view != nil {
            self.desktop?.set(focus: self)
        }
        
        return view
    }
    
    private var resizing: Bool = false {
        didSet {
            if resizing {
                containerView.layer.borderColor = config.tintColor.withAlphaComponent(0.6).cgColor
                containerView.layer.borderWidth = 3
            } else {
                containerView.layer.borderColor = UIColor.systemGray3.cgColor
                containerView.layer.borderWidth = 1/UIScreen.main.scale
            }
        }
    }
    
    private var focus: Bool = false {
        didSet {
            if self.focus {
                parentVC?.view.bringSubviewToFront(self)
                self.layer.shadowOpacity = 0.5
                self.layer.shadowRadius = 30
                self.layer.shadowOffset = CGSize(width: 0, height: 10)
            } else {
                self.layer.shadowOpacity = 0.2
                self.layer.shadowRadius = 5
                self.layer.shadowOffset = CGSize(width: 0, height: 3)
            }
        }
    }
    
    private var fullScreen: Bool = false {
        didSet {
            if fullScreen {
                backupPosition()
                topGap.constant = (desktop?.view?.safeAreaInsets.top ?? 0)
                leftGap.constant = 0
                heightConstant.constant = desktop?.view?.frame.height ?? 400 - (desktop?.view?.safeAreaInsets.top ?? 0)
                widthConstant.constant = desktop?.view?.frame.width ?? 300
            } else {
                recoverPosition()
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutSubviews()
                
            }
        }
    }
    
    func backupPosition(){
        if !fullScreen {
            topGapBackup = topGap.constant
            leftGapBackup = leftGap.constant
            heightConstantBackup = heightConstant.constant
            widthConstantBackup = widthConstant.constant
        }
    }
    
    func recoverPosition(){
        topGap.constant = topGapBackup ?? 0
        leftGap.constant = leftGapBackup ?? 0
        heightConstant.constant = heightConstantBackup ?? 300
        widthConstant.constant = widthConstantBackup ?? 400
    }
    
    func set(constraint top: CGFloat, left: CGFloat, superView: UIView) {
        self.topGap.constant = top
        self.leftGap.constant = left
        self.transform = .identity
        superView.layoutSubviews()
    }
    
    func set(focus: Bool) {
        self.focus = focus
    }
    
    func set(viewControllerMoveTo parent: UIViewController) {
        self.childVC.didMove(toParent: parent)
    }
    
    func handle(touchEvent: UIWindowsWindow.TouchEvent, from sander: UIPanGestureRecognizer) {
        guard let parentVC = self.parentVC else {
            return
        }
        
        switch touchEvent {
        case .moveWindow:
            switch sander.state {
            case .began:
                backupPosition()
            case .changed:
                desktop?.handlePan(changed: self, offsetX: sander.translation(in: parentVC.view).x, offsetY: sander.translation(in: parentVC.view).y)
            case .ended:
                desktop?.handlePan(end: self, offsetX: sander.translation(in: parentVC.view).x, offsetY: sander.translation(in: parentVC.view).y)
                backupPosition()
                if self.fullScreen {self.fullScreen = false}
                self.layoutSubviews()
            default:
                self.transform = .identity
            }
            
        case .resize(let left, let top):
            self.resizing = sander.state == .changed
            switch sander.state {
            case .began:
                oWidth = widthConstant.constant
                oHeight = heightConstant.constant
                backupPosition()
            case .changed:
                self.nWidth = oWidth + sander.translation(in: self).x * (left ? (-1) : (1))
                self.nHeight = oHeight + sander.translation(in: self).y * (top ? (-1) : (1))
            
                if left { self.offsetX = sander.translation(in: parentVC.view).x }
                if top { self.offsetY = sander.translation(in: parentVC.view).y }
            
                if nHeight < parentVC.view.frame.height, nHeight > self.config.minHeight {
                    self.heightConstant.constant = nHeight
                } else {
                    if nHeight > parentVC.view.frame.height {
                        offsetY = oHeight - parentVC.view.frame.height
                    } else {
                        offsetY = oHeight - self.config.minHeight
                    }
                }
                
                if nWidth < parentVC.view.frame.width, nWidth > self.config.minWidth {
                    self.widthConstant.constant = nWidth
                } else {
                    if nWidth > parentVC.view.frame.width {
                        offsetX = oWidth - parentVC.view.frame.width
                    } else {
                        offsetX = oWidth - self.config.minWidth
                    }
                }
            
                desktop?.handlePan(changed: self, offsetX: left ? offsetX : 0, offsetY: top ? offsetY : 0)
                self.layoutSubviews()
            case .ended:
                desktop?.handlePan(end: self, offsetX: left ? offsetX : 0, offsetY: top ? offsetY : 0)
                backupPosition()
                self.layoutSubviews()
            default:
                self.transform = .identity
                widthConstant.constant = oWidth
                heightConstant.constant = oHeight
                self.layoutSubviews()
            }
        }
    }
    
    @objc func handlePan(_ sander: UIPanGestureRecognizer){
        self.handle(touchEvent: .moveWindow, from: sander)
    }
    
    @objc func handlePanTL(_ sander: UIPanGestureRecognizer){
        self.handle(touchEvent: .resize(left: true, top: true), from: sander)
    }
    
    @objc func handlePanTR(_ sander: UIPanGestureRecognizer){
        self.handle(touchEvent: .resize(left: false, top: true), from: sander)
    }
    
    @objc func handlePanBL(_ sander: UIPanGestureRecognizer){
        self.handle(touchEvent: .resize(left: true, top: false), from: sander)
    }
    
    @objc func handlePanBR(_ sander: UIPanGestureRecognizer){
        self.handle(touchEvent: .resize(left: false, top: false), from: sander)
    }
    
    func transformWindows(transform x: CGFloat, y:CGFloat) {
        self.transform = CGAffineTransform(translationX: x, y: y)
    }

    func setUpCornerGestureView(){
        
        self.addSubview(leftBotView)
        self.addSubview(leftTopView)
        self.addSubview(rightBotView)
        self.addSubview(rightTopView)
        
        let panGestureTL = UIPanGestureRecognizer(target: self, action: #selector(handlePanTL))
        let panGestureTR = UIPanGestureRecognizer(target: self, action: #selector(handlePanTR))
        let panGestureBL = UIPanGestureRecognizer(target: self, action: #selector(handlePanBL))
        let panGestureBR = UIPanGestureRecognizer(target: self, action: #selector(handlePanBR))
        
        leftBotView.addGestureRecognizer(panGestureBL)
        leftTopView.addGestureRecognizer(panGestureTL)
        rightBotView.addGestureRecognizer(panGestureBR)
        rightTopView.addGestureRecognizer(panGestureTR)
        
        leftBotView.backgroundColor = .clear
        leftTopView.backgroundColor = .clear
        rightBotView.backgroundColor = .clear
        rightTopView.backgroundColor = .clear
        
        fix(this: leftTopView, into: self, horizontal: .fixLeading(leading: 0, intrinsic: config.cornerResponsRadius), vertical: .fixLeading(leading: 0, intrinsic: config.cornerResponsRadius))
        
        fix(this: leftBotView, into: self, horizontal: .fixLeading(leading: 0, intrinsic: config.cornerResponsRadius), vertical: .fixTrailing(trailing: 0, intrinsic: config.cornerResponsRadius))
        
        fix(this: rightBotView, into: self, horizontal: .fixTrailing(trailing: 0, intrinsic: config.cornerResponsRadius), vertical: .fixTrailing(trailing: 0, intrinsic: config.cornerResponsRadius))
        
        fix(this: rightTopView, into: self, horizontal: .fixTrailing(trailing: 0, intrinsic: config.cornerResponsRadius), vertical: .fixLeading(leading: 0, intrinsic: config.cornerResponsRadius))
    }
}


extension UIWindowsWindow: UIWindowsDelegate {
    func enterfullscreen(){
        self.fullScreen = true
    }
    
    func exitfullscreen(){
        self.fullScreen = false
    }
    
    func closeWindow(){
        if self.fullScreen {
            self.fullScreen = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.removeFromSuperview()
                self.desktop?.remove(window: self)
                self.childVC.navigationController?.removeFromParent()
            }
        } else {
            self.removeFromSuperview()
            self.desktop?.remove(window: self)
            self.childVC.navigationController?.removeFromParent()
        }
    }
    
    func toggleFullScreen() {
        self.fullScreen = !self.fullScreen
    }
}
