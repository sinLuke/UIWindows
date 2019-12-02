//
//  SafeAreaAdjustNavigationViewController.swift
//  iOSWindow
//
//  Created by Luke on 2019-07-29.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

class UIWindowsNavigationController: UINavigationController {
    
    var windowDelegate: UIWindowsDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

    @objc func closeWindow(){

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
