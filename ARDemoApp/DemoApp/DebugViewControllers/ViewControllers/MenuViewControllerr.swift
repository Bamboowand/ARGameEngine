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
    static var ModelPhotoDict = [ String: UIImage ]()

//    let modelNames = ["桌子.usdz", "椅子.usdz", "電腦椅.usdz"]
    var observation: NSKeyValueObservation?
    var viewModel: [ModelLoadViewModel] = [ModelLoadViewModel]() {
        didSet {
            tableView.reloadData()
        }
    }

    weak var callBack: MenuViewSelect?
    // MARK: - UIViewController lifecircle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.register(ModelTableViewCell.self, forCellReuseIdentifier: "Cell")

        LocalLoader.shared.loadModel = { [unowned self] viewModel in
            self.viewModel = viewModel
        }
        self.viewModel = LocalLoader.shared.models

        observation = ARGameEngine.shared.observe(\.focusPlaneSize, options: [.new]) { [unowned self] (_, _) in
            self.tableView.reloadData()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LocalLoader.shared.loadModel = nil
        observation?.invalidate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                       for: indexPath) as? ModelTableViewCell else {
            fatalError("Error regist TableView Cell")
        }
        let str = viewModel[indexPath.row].modelName.components(separatedBy: ".")

        cell.textLabel?.text = str[0]
        cell.textLabel?.textColor = UIColor.black

        if let entitySize = viewModel[indexPath.row].areaSize,
            (entitySize.width > ARGameEngine.shared.focusPlaneSize.width ||
            entitySize.height > ARGameEngine.shared.focusPlaneSize.height ||
            entitySize.width == -1.0 ||
            entitySize.height == -1.0) {
            cell.textLabel?.textColor = UIColor.red
        } else {
            cell.textLabel?.textColor = UIColor.black
        }

//        if let photo = MenuViewController.ModelPhotoDict[modelNames[indexPath.row]] {
//            cell.imageView!.image = photo
//        } else {
//            cell.imageView!.image = UIImage(systemName: "circle")
//        }
        if let image = viewModel[indexPath.row].photo {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(systemName: "circle")
        }
        cell.backgroundColor = UIColor.white
//        cell.imageView!.image = UIImage(system)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callBack?.selectMenuView(selectString: viewModel[indexPath.row].modelName)
        self.dismiss(animated: true, completion: nil)
    }
}
