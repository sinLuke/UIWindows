//
//  DraggableView.swift
//  iOSWindow
//
//  Created by Luke on 2019-07-28.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

protocol UIWindowsWindowDelegate {
    func closeWindow()
}

class UIWindowsWindow: UIView, UIWindowsWindowDelegate {
    
    struct Config {
        var minHeight: CGFloat = 300.0
        var minWeight: CGFloat = 200.0
        var tintColor: UIColor = .systemBlue
        var cornerAdjustRadius: CGFloat = 20.0
        
        init(){}
        
        init(minHeight: CGFloat?, minWeight: CGFloat?, tintColor: UIColor?, cornerAdjustRadius: CGFloat?) {
            if let minHeight = minHeight {
                self.minHeight = minHeight
            }
            if let minWeight = minWeight {
                self.minWeight = minWeight
            }
            if let tintColor = tintColor {
                self.tintColor = tintColor
            }
            if let cornerAdjustRadius = cornerAdjustRadius {
                self.cornerAdjustRadius = cornerAdjustRadius
            }
        }
    }
    
    var config = Config()
    
    var topGap: NSLayoutConstraint!
    var leftGap: NSLayoutConstraint!
    var heightConstant: NSLayoutConstraint!
    var widthConstant: NSLayoutConstraint!
    
    var fullTop: NSLayoutConstraint!
    var fullBottom: NSLayoutConstraint!
    var fullLeft: NSLayoutConstraint!
    var fullRight: NSLayoutConstraint!
    
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
    
    var barGestureView: UIView!
    
    let containerView = UIView()
    var navigationVC = UIWindowsNavigationController()
    
    var childVC: UIViewController
    weak var parentVC: UIViewController?
    weak var manager: UIWindowsManager?

    
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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view != nil {
            self.manager?.set(focus: self)
        }
        
        if let allWindowsViewController = self.childVC as? AllWindowsViewController {
            allWindowsViewController.tableView.reloadData()
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
                self.childVC.view.alpha = 1.0
            } else {
                self.layer.shadowOpacity = 0.2
                self.layer.shadowRadius = 5
                self.layer.shadowOffset = CGSize(width: 0, height: 3)
                self.childVC.view.alpha = 0.4
            }
        }
    }
    
    private var fullScreen: Bool = false {
        didSet {
            
            self.frame = CGRect(x: self.leftGap.constant, y: self.topGap.constant, width: self.widthConstant.constant, height: self.heightConstant.constant)
            
            
            
            self.topGap.isActive = !fullScreen
            self.leftGap.isActive = !fullScreen
            self.heightConstant.isActive = !fullScreen
            self.widthConstant.isActive = !fullScreen
            
            self.fullTop.isActive = fullScreen
            self.fullBottom.isActive = fullScreen
            self.fullLeft.isActive = fullScreen
            self.fullRight.isActive = fullScreen
            
            UIView.animate(withDuration: 0.3) {
                self.layoutSubviews()
                
            }
        }
    }
    
    init(childVC: UIViewController, with config: Config?) {
        
        if let config = config {
            self.config = config
        }
        
        self.childVC = childVC
            
        super.init(frame: CGRect(x: 10, y: 10, width: self.config.minWeight, height: self.config.minHeight))
        
        self.addSubview(containerView)
        self.backgroundColor = .clear
        self.setUpCornerGestureView()

        fixInto(this: containerView, view: self, horizontal: .fill(leading: 0, trailing: 0), vertical: .fill(leading: 0, trailing: 0))
        
        containerView.backgroundColor = .systemBackground
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 8
        containerView.layer.borderColor = UIColor.systemGray3.cgColor
        containerView.layer.borderWidth = 1/UIScreen.main.scale
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowRadius = 30
        self.layer.shadowOpacity = 0.5
        
        if let childNVC = childVC as? UINavigationController {
            containerView.addSubview(childNVC.view)
            
            fixInto(this: childNVC.view, view: containerView, horizontal: .fill(leading: 0, trailing: 0), vertical: .fill(leading: 0, trailing: 0))
            
            self.barGestureView = childNVC.navigationBar
            
        } else {
            navigationVC = UIWindowsNavigationController(rootViewController: childVC)
            containerView.addSubview(navigationVC.view)
            
            
            fixInto(this: navigationVC.view, view: containerView, horizontal: .fill(leading: 0, trailing: 0), vertical: .fill(leading: 0, trailing: 0))
            
            self.barGestureView = navigationVC.navigationBar
            
            navigationVC.draggableDelegate = self
        }
        
        
                
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        
        doubleTapGesture.numberOfTapsRequired = 2

        barGestureView.addGestureRecognizer(panGesture)
        barGestureView.addGestureRecognizer(doubleTapGesture)

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func handleTap(_ sander: UITapGestureRecognizer){
        if sander.state == .recognized {
            self.fullScreen = !self.fullScreen
        }
    }
    func closeWindow(){
        if self.fullScreen {
            self.fullScreen = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.removeFromSuperview()
                self.manager?.remove(window: self)
                self.childVC.navigationController?.removeFromParent()
            }
        } else {
            self.removeFromSuperview()
            self.manager?.remove(window: self)
            self.childVC.navigationController?.removeFromParent()
        }
    }
    
    @objc func handlePan(_ sander: UIPanGestureRecognizer){
        guard let parentVC = self.parentVC else {
            return
        }
        switch sander.state {
        case .changed:
            manager?.handlePan(changed: self, offsetX: sander.translation(in: parentVC.view).x, offsetY: sander.translation(in: parentVC.view).y)
        case .ended:
            manager?.handlePan(end: self, offsetX: sander.translation(in: parentVC.view).x, offsetY: sander.translation(in: parentVC.view).y)
            self.fullScreen = false
        default:
            self.transform = .identity
        }
    }
    
    @objc func handlePanTL(_ sander: UIPanGestureRecognizer){
        guard let parentVC = self.parentVC else {
            return
        }
        self.resizing = sander.state == .changed
        switch sander.state {
        case .began:
            oWidth = widthConstant.constant
            oHeight = heightConstant.constant
        case .changed:
            self.nWidth = oWidth - sander.translation(in: self).x
            self.nHeight = oHeight - sander.translation(in: self).y
            self.offsetX = sander.translation(in: parentVC.view).x
            self.offsetY = sander.translation(in: parentVC.view).y
            if nHeight < parentVC.view.frame.height, nHeight > self.config.minHeight {
                self.heightConstant.constant = nHeight
            } else {
                if nHeight > parentVC.view.frame.height {
                    offsetY = oHeight - parentVC.view.frame.height
                } else {
                    offsetY = oHeight - self.config.minHeight
                }
            }
            
            if nWidth < parentVC.view.frame.width, nWidth > self.config.minWeight {
                self.widthConstant.constant = nWidth
            } else {
                if nWidth > parentVC.view.frame.width {
                    offsetX = oWidth - parentVC.view.frame.width
                } else {
                    offsetX = oWidth - self.config.minWeight
                }
            }
            manager?.handlePan(changed: self, offsetX: offsetX, offsetY: offsetY)
            self.layoutSubviews()
        case .ended:
            manager?.handlePan(end: self, offsetX: offsetX, offsetY: offsetY)
            self.layoutSubviews()
        default:
            self.transform = .identity
            widthConstant.constant = oWidth
            heightConstant.constant = oHeight
            self.layoutSubviews()
        }
    }
    
    @objc func handlePanTR(_ sander: UIPanGestureRecognizer){
        guard let parentVC = self.parentVC else {
            return
        }
        self.resizing = sander.state == .changed
        switch sander.state {
        case .began:
            oWidth = widthConstant.constant
            oHeight = heightConstant.constant
        case .changed:
            self.nWidth = oWidth + sander.translation(in: self).x
            self.nHeight = oHeight - sander.translation(in: self).y
            self.offsetY = sander.translation(in: parentVC.view).y
            if nHeight < parentVC.view.frame.height, nHeight > self.config.minHeight {
                self.heightConstant.constant = nHeight
            } else {
                if nHeight > parentVC.view.frame.height {
                    offsetY = oHeight - parentVC.view.frame.height
                } else {
                    offsetY = oHeight - self.config.minHeight
                }
            }
            
            if nWidth < parentVC.view.frame.width, nWidth > self.config.minWeight {
                self.widthConstant.constant = nWidth
            }
            manager?.handlePan(changed: self, offsetX: 0, offsetY: offsetY)
            self.layoutSubviews()
        case .ended:
            manager?.handlePan(end: self, offsetX: 0, offsetY: offsetY)
            self.layoutSubviews()
        default:
            self.transform = .identity
            widthConstant.constant = oWidth
            heightConstant.constant = oHeight
            self.layoutSubviews()
        }
    }
    
    @objc func handlePanBL(_ sander: UIPanGestureRecognizer){
        guard let parentVC = self.parentVC else {
            return
        }
        self.resizing = sander.state == .changed
        switch sander.state {
        case .began:
            oWidth = widthConstant.constant
            oHeight = heightConstant.constant
        case .changed:
            self.nWidth = oWidth - sander.translation(in: self).x
            self.nHeight = oHeight + sander.translation(in: self).y
            self.offsetX = sander.translation(in: parentVC.view).x
            
            if nHeight < parentVC.view.frame.height, nHeight > self.config.minHeight {
                self.heightConstant.constant = nHeight
            }
            
            if nWidth < parentVC.view.frame.width, nWidth > self.config.minWeight {
                self.widthConstant.constant = nWidth
            } else {
                if nWidth > parentVC.view.frame.width {
                    offsetX = oWidth - parentVC.view.frame.width
                } else {
                    offsetX = oWidth - self.config.minWeight
                }
            }
            manager?.handlePan(changed: self, offsetX: offsetX, offsetY: 0)
            self.layoutSubviews()
        case .ended:
            manager?.handlePan(end: self, offsetX: offsetX, offsetY: 0)
            self.layoutSubviews()
        default:
            self.transform = .identity
            widthConstant.constant = oWidth
            heightConstant.constant = oHeight
            self.layoutSubviews()
        }
    }
    
    @objc func handlePanBR(_ sander: UIPanGestureRecognizer){
        guard let parentVC = self.parentVC else {
            return
        }
        self.resizing = sander.state == .changed
        switch sander.state {
        case .began:
            oWidth = widthConstant.constant
            oHeight = heightConstant.constant
        case .changed:
            self.nWidth = oWidth + sander.translation(in: self).x
            self.nHeight = oHeight + sander.translation(in: self).y
            if nHeight < parentVC.view.frame.height, nHeight > self.config.minHeight {
                self.heightConstant.constant = nHeight
            }
            
            if nWidth < parentVC.view.frame.width, nWidth > self.config.minWeight {
                self.widthConstant.constant = nWidth
            }
            
            self.layoutSubviews()
        case .ended:
            self.layoutSubviews()
        default:
            self.transform = .identity
            widthConstant.constant = oWidth
            heightConstant.constant = oHeight
            self.layoutSubviews()
        }
    }
    
    func transformWindows(transform x: CGFloat, y:CGFloat) {
        self.transform = CGAffineTransform(translationX: x, y: y)
    }

    func setUpCornerGestureView(){
        
        self.addSubview(leftBotView)
        self.addSubview(leftTopView)
        self.addSubview(rightBotView)
        self.addSubview(rightTopView)
        
        rightBotView.backgroundColor = .blue
        
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
        
        fixInto(this: leftTopView, view: self, horizontal: .fixLeading(leading: 0, intrinsic: config.cornerAdjustRadius), vertical: .fixLeading(leading: 0, intrinsic: 20))
        
        fixInto(this: leftBotView, view: self, horizontal: .fixLeading(leading: 0, intrinsic: config.cornerAdjustRadius), vertical: .fixTrailing(trailing: 0, intrinsic: config.cornerAdjustRadius))
        
        fixInto(this: rightBotView, view: self, horizontal: .fixTrailing(trailing: 0, intrinsic: config.cornerAdjustRadius), vertical: .fixTrailing(trailing: 0, intrinsic: config.cornerAdjustRadius))
        
        fixInto(this: rightTopView, view: self, horizontal: .fixTrailing(trailing: 0, intrinsic: config.cornerAdjustRadius), vertical: .fixLeading(leading: 0, intrinsic: config.cornerAdjustRadius))
    }
}
