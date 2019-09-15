//
//  ContainerViewController.swift
//  iOSWindow
//
//  Created by Luke on 2019-07-28.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit
import WebBrowser
import UIWindows

class ContainerViewController: UIViewController {
    
    var manager : UIWindowsManager!
    
    override func viewDidLoad() {
        manager = UIWindowsManager(on: self)
        view.backgroundColor = .secondarySystemFill
    }

    @IBAction func addWeb(_ sender: Any) {
        let webBrowserViewController = WebBrowserViewController()
        webBrowserViewController.language = .english
        webBrowserViewController.loadURLString("https://www.google.ca")
        let config = UIWindowsWindow.Config()
        let windowView = UIWindowsWindow(childVC: webBrowserViewController, with: config)
        manager.add(new: windowView)
    }

    
    @IBAction func closeAll(_ sender: Any) {
        manager.closeAllWindows()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
