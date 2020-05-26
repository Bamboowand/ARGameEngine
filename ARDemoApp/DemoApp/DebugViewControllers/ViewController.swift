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
import SceneKit
import Social

// ToDo: Memory leak issure

class ViewController: UIViewController {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var operactedView: UIView!
    var currentEntity: VirtualModelEntity?

    @IBOutlet weak var arView: ARGameView!
    lazy var viewInteraction: ViewInteraction = {
        let view = ViewInteraction(view: self.arView)
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBtn.isHidden = true
        self.addBtn.alpha = 0.0
        self.clearBtn.isHidden = true
        self.clearBtn.alpha = 0.0
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
        viewInteraction.selectedEntity = nil

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebInteraction.clearTemp()
    }

    // MARK: - Action methods
    @IBAction func showMenuAction(_ sender: UIButton) {
        let menuController = MenuViewController()
        menuController.modalPresentationStyle = .popover
        menuController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 2.0 / 3.0,
                                                     height: 44 * 3)
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

        if currentEntity == nil {
            return
        }

        viewInteraction.selectedEntity = currentEntity!
//        currentEntity!.referenceNode.scale = SCNVector3(0.001, 0.001, 0.001)
        self.arView.placeModel(currentEntity!)
        self.hideView(uiComponent: self.addBtn)
        self.unhideView(uiComponent: self.clearBtn)
    }

    @IBAction func clearAction(_ sender: Any) {
        self.arView.clearScene()
        self.hideView(uiComponent: self.clearBtn)
        WebInteraction.clearTemp()
    }

    @IBAction func changeTexture(_ sender: Any) {
        if let node = self.viewInteraction.selectedEntity?.referenceNode.childNode(withName: "mesh_primitive0",
                                                                                   recursively: true) {
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//            node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//            for childNode in node.childNodes {
//                guard let texture = childNode.geometry?.firstMaterial else {
//                    continue
//                }
//                texture.diffuse.contents = UIColor.red
//            }
        }
    }

    @IBAction func takePictureAction(_ sender: Any) {
        self.arView.takePicture { [weak self] photo in
//            UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
            DispatchQueue.main.async {
                let activityViewController = UIActivityViewController(activityItems: [photo],
                                                                      applicationActivities: nil)
                self?.present(activityViewController, animated: true, completion: nil)
            }

        }

    }

    func hideOperactedView() {
        UIView.animate(withDuration: 0.4, animations: { [unowned self] in
            self.operactedView.alpha = 0.0
        },
        completion: { [unowned self] _ in
            self.operactedView.isHidden = true
        })
    }

    func unhideOperactedView() {
        UIView.animate(withDuration: 0.4, animations: { [unowned self] in
            self.operactedView.isHidden = false
            self.operactedView.alpha = 1.0
        })
    }

    func hideView(uiComponent: UIView) {
        UIView.animate(withDuration: 0.4, animations: {
            uiComponent.alpha = 0.0
        },
        completion: { _ in
            uiComponent.isHidden = true
        })
    }

    func unhideView(uiComponent: UIView) {
        UIView.animate(withDuration: 0.4, animations: {
            uiComponent.isHidden = false
            uiComponent.alpha = 1.0
        })
    }

}

// MARK: - Delegate
extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

extension ViewController: MenuViewSelect {
    func selectMenuView(selectString: String) {
        VirtualModelEntityLoader.loadAsync(name: selectString) { [weak self] virtual in
            DispatchQueue.main.async { [weak self] in
                MenuViewController.ModelPhotoDict[virtual.referenceNode.referenceURL.lastPathComponent] = virtual.photo
                self?.currentEntity = virtual

                self?.unhideView(uiComponent: self!.addBtn)

                if ARGameEngine.shared.modelEntitys.count > 0 {
                    self?.unhideView(uiComponent: self!.clearBtn)
                }

            }
        }
    }
}

extension ViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {

    func openQuick() {
        WebInteraction.downloadFile(url: URL(string: "https://bamboowand.github.io/retrotv.usdz")!) { fileURL in
            VirtualModelEntityLoader.loadAsync(url: fileURL) { [weak self] entity in
                self?.arView.placeModel(entity)
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
        1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        do {
            let tempArray = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            var url: URL?
            for fileString in tempArray {
                url = URL(fileURLWithPath: NSTemporaryDirectory() + fileString)
            }
            return url! as QLPreviewItem
        } catch {
            fatalError("Not found temporary directory")
        }
    }
}
