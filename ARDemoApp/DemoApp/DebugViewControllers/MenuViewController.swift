//
//  MenuViewController.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/15.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit

protocol MenuViewSelect: class {
    func selectMenuView(selectString: String)
}

class MenuViewController: UITableViewController {
    
    static var ModelPhotoDict = [ String : UIImage ]()
        
    let modelNames = ["桌子.usdz", "椅子.usdz", "電腦椅.usdz"]
    
    weak var callBack: MenuViewSelect? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return modelNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let str = modelNames[indexPath.row].components(separatedBy: ".")
        cell.textLabel?.text = str[0]
        if let photo = MenuViewController.ModelPhotoDict[modelNames[indexPath.row]] {
            cell.imageView!.image = photo
        }
        else {
            cell.imageView!.image = UIImage(systemName: "circle")
        }
        cell.backgroundColor = UIColor.white
        cell.textLabel?.textColor = UIColor.black
//        cell.imageView!.image = UIImage(system)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callBack?.selectMenuView(selectString: modelNames[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
