//
//  ARGameEngine.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/15.
//  Copyright © 2020 Jacob. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit
import ARKit

class ARGameEngine: NSObject {
    
    weak var view: ARSCNView? = nil
    weak var scene: SCNScene? = nil
    weak var arSession: ARSession? = nil
    // MARK: - Property storge
    private var _modelEntitys = [VirtualModelEntity]()
    
    // MARK: - Singgleton init
    struct Static {
        internal static var instance: ARGameEngine?
    }
        
    public class var shared: ARGameEngine {
        if Static.instance == nil {
            Static.instance = ARGameEngine()
        }
        return Static.instance!
    }
    
    private override init() {
        super.init()
        print("J_🔧 ARGameEngine init")
    }
        
    func dispose() {
        ARGameEngine.Static.instance = nil
        print("J_🗡 ARGameEngine disposed singleton instance")
    }
        
    deinit {
        print("J_☠️ ARGameEngine release")
    }
    
    // MARK: - Model Data Operation
    private func addModel(_ newModel: VirtualModelEntity) {
        _modelEntitys.append(newModel)
    }
    
    internal func clearScene() {
        // Reverse the indices so we don't trample over indices as objects are removed.
        for index in _modelEntitys.indices.reversed() {
            removeModelEntity(at: index)
        }
    }
    
    internal func removeModelEntity(at index: Int) {
        guard _modelEntitys.indices.contains(index) else { return }
        
        // Stop the object's tracked ray cast.
        _modelEntitys[index].stopTrackedRaycast()
        
        // Remove the visual node from the scene graph.
        if let anchor = _modelEntitys[index].anchor {
            arSession?.remove(anchor: anchor)
            _modelEntitys[index].anchor = nil
        }
        _modelEntitys[index].raycastQueue = nil
        _modelEntitys[index].referenceNode.removeFromParentNode()
        
        // Recoup resources allocated by the object.
        _modelEntitys[index].referenceNode.unload()
        _modelEntitys.remove(at: index)
    }
    
    // MARK: Place model flow
    internal func placeModel(_ newModel: VirtualModelEntity, anchor: ARAnchor? = nil) {
        addModel(newModel)
        self.view?.prepare([newModel.referenceNode], completionHandler: { [weak self] _ in
            self?.scene?.rootNode.addChildNode(newModel.referenceNode)
        })
    }
    
}

