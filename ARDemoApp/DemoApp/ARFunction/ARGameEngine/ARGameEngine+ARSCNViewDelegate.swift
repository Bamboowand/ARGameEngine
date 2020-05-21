//
//  ARGameEngine+ARSCNViewDelegate.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/15.
//  Copyright © 2020 Jacob. All rights reserved.
//

import ARKit
import SceneKit

extension ARGameEngine: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.focusNode.updateFocusNode()
    }
    
    // MARK: - 
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        
//        DispatchQueue.main.async {
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                let plane = ARSCNPlaneGeometry(device: MTLCreateSystemDefaultDevice()!)
//                plane?.update(from: planeAnchor.geometry)
////                plane?.firstMaterial?.colorBufferWriteMask = .alpha
//                plane?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.7)
//                node.geometry = plane
//                node.name = "Occlusion Plane"
                
//                guard let occulusion = node.childNode(withName: "plane", recursively: false) else {
//                    let newOcculusion = SCNNode()
//                    newOcculusion.name = "plane"
//                    node.addChildNode(newOcculusion)
//                    return
//                }
//
//                if planeAnchor.alignment == .horizontal {
//                    occulusion.geometry = plane?.copy() as? SCNGeometry
//                    occulusion.geometry?.firstMaterial?.colorBufferWriteMask = .all
//                    occulusion.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//                }
                
//            }
//        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
    }
}
