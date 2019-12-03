//
//  MenuViewController.swift
//  ExampleForUIWindows
//
//  Created by Luke Yin on 2019-12-03.
//  Copyright © 2019 Luke Yin. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct CellModel {
        let title: String
        let didSelect: ()->()
    }
    
    var cells: [CellModel] = []
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    func configCells(callBack: ViewControllerCallBackDelegate){
        self.cells = [
           CellModel(title: "Image From Camera", didSelect: {
               callBack.createCameraWindow()
           }),
           CellModel(title: "Image From Library", didSelect: {
               callBack.createImagePickerWindow()
           }),
           CellModel(title: "File Browser", didSelect: {
               callBack.createDocumentWindow()
           })
        ]
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = cells[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cells[indexPath.row].didSelect()
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
