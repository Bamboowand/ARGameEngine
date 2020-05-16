//
//  ViewController.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/14.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit
import ARKit
import QuickLook


class ViewController: UIViewController {
    
    var currentEntity: VirtualModelEntity?

    @IBOutlet weak var arView: ARGameView!
    lazy var viewInteraction = ViewInteraction(view: self.arView)
    override func viewDidLoad() {
        super.viewDidLoad()
//        let arView = ARGameView()
//        arView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(arView)
//        NSLayoutConstraint.activate([
//            arView.topAnchor.constraint(equalTo: view.topAnchor),
//            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
//        ])
        
        
        arView.run()
        viewInteraction.selectedNode = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebInteraction.clearTemp()
    }

    @IBAction func showMenuAction(_ sender: UIButton) {
        let menuController = MenuViewController()
        menuController.modalPresentationStyle = .popover
        menuController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 2.0 / 3.0,
                                                     height: UIScreen.main.bounds.width * 2.0 / 3.0)
        menuController.callBack = self
        if let popover = menuController.popoverPresentationController {
            popover.permittedArrowDirections = .up
            popover.sourceRect = CGRect(origin: CGPoint.zero, size: sender.frame.size)
            popover.sourceView = sender
            popover.delegate = self
        }
        self.present(menuController, animated: true, completion: nil)
    }
        
    @IBAction func addObjectAction(_ sender: Any) {

        guard let result = self.arView.hitTest(CGPoint(x: UIScreen.main.bounds.width / 2.0,
                                                       y: UIScreen.main.bounds.height / 2.0),
                                               types: .existingPlane).first,
        currentEntity != nil
        else {
            return
        }
        viewInteraction.selectedNode = currentEntity!.referenceNode
        currentEntity!.referenceNode.simdWorldTransform = result.worldTransform
        currentEntity!.referenceNode.scale = SCNVector3(0.001, 0.001, 0.001)
        self.arView.addModelEntity(currentEntity!)
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.arView.clearScene()
        WebInteraction.clearTemp()
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ViewController: MenuViewSelect {
    func selectMenuView(selectString: String) {
        VirtualModelEntity.loadAsync(name: selectString) { [weak self] virtual in
            DispatchQueue.main.async {
                    MenuViewController.ModelPhotoDict[virtual.referenceNode.referenceURL.lastPathComponent] = virtual.photo
                    self?.currentEntity = virtual
            }
        }
    }
}

extension ViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    func openQuick() {
        WebInteraction.downloadFile(url: URL(string: "https://bamboowand.github.io/retrotv.usdz")!) { fileURL in
            VirtualModelEntity.loadAsync(url: fileURL) { [weak self] entity in
                self?.arView.addModelEntity(entity)
                DispatchQueue.main.async {
                    let quick = QLPreviewController()
                    quick.dataSource = self
                    quick.delegate = self
                    self?.present(quick, animated: true, completion: nil)
                }
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
        
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let tempArray = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        
        var url: URL? = nil
        for fileString in tempArray {
            url = URL(fileURLWithPath: NSTemporaryDirectory() + fileString)
        }
        
        return url! as QLPreviewItem
    }
}


