//
//  ViewInteraction.swift
//  EasyInteraction
//
//  Created by ChenWei on 2020/4/13.
//  Copyright © 2020 Jacob. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class ViewInteraction: NSObject {
    let scnView: ARSCNView
    
    var selectedNode: SCNNode?
    private var lastRotaion: Float = 0.0
    
    init(view: ARSCNView) {
        self.scnView = view
        super.init()
        self.addGestureForView(view: self.scnView)
    }
    
    private func addGestureForView(view: ARSCNView) {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapped(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        view.addGestureRecognizer(rotationGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(panGesture)
        
    }
    
    @objc
    func didTapped(_ gesture: UITapGestureRecognizer) {
        let tappedLoaction = gesture.location(in: self.scnView)
        if let node = self.findNode(point: tappedLoaction) {
            self.selectedNode = node
        }
    }
    
    @objc
    func didDoubleTapped(_ gesture: UITapGestureRecognizer) {
        self.selectedNode = nil
    }
        
    @objc
    func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let node = self.selectedNode else {
            return
        }
        
        switch gesture.state {
        case .began:
            gesture.scale = CGFloat(node.scale.x)
        case .changed:
            var newScale: CGFloat = 1.0
            if gesture.scale < 0.0001 {
                newScale = 0.001
            }
            else if gesture.scale > 5 {
                newScale = 5.0
            }
            else {
                newScale = gesture.scale
            }
            node.scale = SCNVector3(newScale, newScale, newScale)
        default:
            break
        }
    }
        
    @objc
    func didRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let node = self.selectedNode else {
            return
        }
        
        switch gesture.state {
        case .changed:
            node.eulerAngles.y = self.lastRotaion - Float(gesture.rotation)
        case .ended:
            self.lastRotaion -= Float(gesture.rotation)
        default:
            break
        }
    }
        
    @objc
    func didPan(_ gesture: UIPanGestureRecognizer) {
        guard let node = self.selectedNode else {
            return
        }
        
        switch gesture.state {
        case .changed where gesture.numberOfTouches == 1 :
            let translation = gesture.translation(in: scnView)
            let current = scnView.projectPoint(node.position)
            let updatePoint = CGPoint(x: CGFloat(current.x) + translation.x, y: CGFloat(current.y) + translation.y)
//            self.translationByRaycast(node: node, basedOn: updatePoint)
            self.translationByHitTest(node: node, basedOn: updatePoint)
            
            gesture.setTranslation(.zero, in: scnView)
        case .changed where gesture.numberOfTouches == 2:
            if gesture.verticalDirection(target: scnView) == .Up {
                node.position.y += 0.01
            }
            else {
                node.position.y -= 0.01
            }
        default:
            break
        }
    }
    
    func findNode(point: CGPoint) -> SCNNode? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = scnView.hitTest(point, options: hitTestOptions)
        return hitTestResults.lazy.compactMap { result in
            ViewInteraction.existingObjectContainingNode(result.node)
        }.first
    }
    
    static func existingObjectContainingNode(_ node: SCNNode) -> SCNReferenceNode? {
        if let virtualObjectRoot = node as? SCNReferenceNode {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
        
    fileprivate func translationByRaycast(node: SCNNode, basedOn screenPos: CGPoint) {
        guard let query = scnView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: .horizontal),
            let result = scnView.session.raycast(query).first else {
            return
        }
        
        node.simdPosition = result.worldTransform.translation
        
    }
    
    fileprivate func translationByHitTest(node: SCNNode, basedOn screenPos: CGPoint) {
        guard let result = scnView.hitTest(screenPos, types: .existingPlane).first else {
            return
        }
        
        node.simdPosition = result.worldTransform.translation
        
    }
}


extension float4x4 {
    var translation: vector_float3 {
        let translate = self.columns.3
        return vector_float3(translate.x, translate.y, translate.z)
    }
}

extension UIPanGestureRecognizer {

    enum GestureDirection {
        case Up
        case Down
        case Left
        case Right
    }

    /// Get current vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func verticalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).y > 0 ? .Down : .Up
    }

    /// Get current horizontal direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func horizontalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).x > 0 ? .Right : .Left
    }

    /// Get a tuple for current horizontal/vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func versus(target: UIView) -> (horizontal: GestureDirection, vertical: GestureDirection) {
        return (self.horizontalDirection(target: target), self.verticalDirection(target: target))
    }

}

