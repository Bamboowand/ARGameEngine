//
//  WebDemoViewController.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/18.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class WebDemoViewController: UIViewController {

    @IBOutlet weak var arView: ARGameView!

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.run()
    }

    // MARK: Button action
    @IBAction func showMenuAction(_ sender: UIButton) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.width / 5, height: self.view.frame.width / 5)
        layout.scrollDirection = .vertical
        let menu = MenuCollectionViewController(collectionViewLayout: layout)
        menu.callBackDelegate = self
        menu.modalPresentationStyle = .popover
        if let popover = menu.popoverPresentationController {
            popover.permittedArrowDirections = .up
            popover.sourceRect = CGRect(origin: CGPoint.zero, size: sender.frame.size)
            popover.sourceView = sender
            popover.delegate = self
        }
        self.present(menu, animated: true, completion: nil)
    }

    @IBAction func clearAction(_ sender: Any) {
        do {
            let tempArray = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            for fileString in tempArray {
                try FileManager.default.removeItem(atPath: NSTemporaryDirectory() + fileString)
            }

        } catch let error {
            print("Error: Fail to read url, \(error.localizedDescription)")
        }

        APIManager.ModelDictionary.removeAll()
    }
}

extension WebDemoViewController: MenuCallBack {
    func selectEntity(_ object: VirtualModelEntity) {
        object.referenceNode.scale = SCNVector3(0.01, 0.01, 0.01)
        arView.placeModel(object)
    }
}

extension WebDemoViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
