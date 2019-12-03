//
//  ViewController.swift
//  ExampleForUIWindows
//
//  Created by Luke Yin on 2019-12-03.
//  Copyright © 2019 Luke Yin. All rights reserved.
//

import UIKit
import UIWindows

class ViewController: UIViewController {
    
    var desktop: UIDesktop!
    
    var menuViewController: MenuViewController!
    var menuWindow: UIWindowsWindow!
    
    var documentPickerViewController: UIDocumentPickerViewController!
    var documentPickerWindow: UIWindowsWindow!
    
    var imagePickerController: UIImagePickerController!
    var imagePickerWindow: UIWindowsWindow!
    
    var cameraController: UIImagePickerController!
    var cameraWindow: UIWindowsWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.desktop = UIDesktop(makeViewControllerAsDesktop: self)
        desktop.delegate = self
        
        // setup menu
        self.menuViewController = MenuViewController(nibName: "MenuViewController", bundle: nil)
        self.menuWindow = UIWindowsWindow(childVC: self.menuViewController, with: .defaultConfig)
        
        // set up document
        setupDocument()
        
        // setup image picker
        setupImagePicker()
        
        // setup camera
        setupCamera()
    }
    
    func setupImagePicker() {
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = true
        self.imagePickerController.mediaTypes = ["public.image", "public.movie"]
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerWindow = UIWindowsWindow(childVC: imagePickerController, with: .defaultConfig)
    }
    
    func setupDocument(){
        self.documentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.content", "public.text", "public.source-code ", "public.image", "public.audiovisual-content", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt"], in: .open)
        self.documentPickerViewController.delegate = self
        self.documentPickerWindow = UIWindowsWindow(childVC: self.documentPickerViewController, with: .defaultConfig)
    }
    
    func setupCamera(){
        self.cameraController = UIImagePickerController()
        self.cameraController.delegate = self
        self.cameraController.allowsEditing = true
        self.cameraController.mediaTypes = ["public.image", "public.movie"]
        self.cameraController.sourceType = .camera
        self.cameraWindow = UIWindowsWindow(childVC: cameraController, with: .defaultConfig)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.desktop.add(new: self.menuWindow)
        menuViewController.configCells(callBack: self)
    }
    
    func removeWindow(contain picker:UIImagePickerController) {
        if picker == self.imagePickerController {
            self.imagePickerWindow.closeWindow()
            self.setupImagePicker()
        }
        if picker == self.cameraController {
            self.cameraWindow.closeWindow()
            self.setupCamera()
        }
    }
}

protocol ViewControllerCallBackDelegate {
    func createImageWindow(using image: UIImage)
    func createDocumentWindow()
    func createImagePickerWindow()
    func createCameraWindow()
}

extension ViewController: ViewControllerCallBackDelegate {
    func createImagePickerWindow() {
        self.desktop.add(new: self.imagePickerWindow)
    }
    
    func createCameraWindow() {
        self.desktop.add(new: self.cameraWindow)
    }
    
    func createDocumentWindow() {
        self.desktop.add(new: self.documentPickerWindow)
    }
    
    func createImageWindow(using image: UIImage) {
        let imageViewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
        imageViewController.image = image
        let imageWindow = UIWindowsWindow(childVC: imageViewController, with: .defaultConfig)
        self.desktop.add(new: imageWindow)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        return
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        self.createImageWindow(using: image)
        self.removeWindow(contain: picker)
    }
}

extension ViewController: UINavigationControllerDelegate { }

extension ViewController: UIDocumentPickerDelegate { }

extension ViewController: UIDesktopDelegate {
    func destop(desktop: UIDesktop, shouldClose window: UIWindowsWindow) -> Bool {
        return !(window.childVC is MenuViewController)
    }
}
