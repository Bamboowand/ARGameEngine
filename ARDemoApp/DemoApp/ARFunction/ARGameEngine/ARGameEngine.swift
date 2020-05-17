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
    public let focusNode = FocusSquare()
    weak var view: ARGameView? {
        didSet {
            self.focusNode.viewDelegate = view
            self.scene?.rootNode.addChildNode(self.focusNode)
        }
    }
    weak var scene: SCNScene? = nil
    weak var arSession: ARSession? = nil
    // MARK: - Property storge
    private(set) var _modelEntitys = [VirtualModelEntity]()
    private let _updateQueue = DispatchQueue(label: "com.argame_engine_j.serial_scenekit_queue")
    
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
    
    // MARK: - Place model flow
    internal func placeModel(_ newModel: VirtualModelEntity, point: CGPoint? = nil) {
        if _modelEntitys.contains(where: { $0.identity == newModel.identity }) && !newModel.shouldUpdateAnchor {
            return
        }
        
        self.view?.prepare([newModel.referenceNode], completionHandler: { [weak self] _ in
            guard let screenPos = point != nil ? point : self?.view?.screenCenter,
                let query = self?.view?.raycastQuery(from: screenPos,
                                                       allowing: .estimatedPlane,
                                                       alignment: newModel.allowedAlignment),
            let result = self?.arSession?.raycast(query).first else { return }
            
            newModel.raycastQueue = query
            newModel.mostRecentInitialPlacementResult = result
            
            let trackedRaycast = self?.createTrackedRaycastAndSet3DPosition(of: newModel,
                                                                            from: query,
                                                                            withInitialResult: result)
            newModel.raycast = trackedRaycast
        })
    }
    
    internal func addOrUpdataAnchor(for object: VirtualModelEntity) {
        _updateQueue.async { [unowned self] in
            if let anchor = object.anchor {
                self.arSession?.remove(anchor: anchor)
            }
            let newAnchor = ARAnchor(transform: object.referenceNode.simdTransform)
            object.anchor = newAnchor
            self.arSession?.add(anchor: newAnchor)
        }
    }
    
    // - Tag: GetTrackedRaycast
    internal func createTrackedRaycastAndSet3DPosition(of virtualObject: VirtualModelEntity,
                                              from query: ARRaycastQuery,
                                              withInitialResult initialResult: ARRaycastResult? = nil) -> ARTrackedRaycast?
    {
        if let initialResult = initialResult {
//            virtualObject.referenceNode.simdTransform = initialResult.worldTransform
            virtualObject.referenceNode.simdWorldPosition = initialResult.worldTransform.translation
            virtualObject.referenceNode.simdWorldOrientation = initialResult.worldTransform.orientation
        }
        
        return arSession?.trackedRaycast(query) { (results) in
            self.setVirtualObject3DPosition(results, with: virtualObject)
        }
    }
    
    // - Tag: ProcessRaycastResults
    private func setVirtualObject3DPosition(_ results: [ARRaycastResult], with virtualObject: VirtualModelEntity) {
        
        guard let result = results.first else {
            fatalError("Unexpected case: the update handler is always supposed to return at least one result.")
        }
        
//        virtualObject.referenceNode.simdTransform = result.worldTransform
        virtualObject.referenceNode.simdWorldPosition = result.worldTransform.translation
        virtualObject.referenceNode.simdWorldOrientation = result.worldTransform.orientation
        
        // If the virtual object is not yet in the scene, add it.
        if virtualObject.referenceNode.parent == nil {
            addModel(virtualObject)
            scene?.rootNode.addChildNode(virtualObject.referenceNode)
            virtualObject.shouldUpdateAnchor = true
        }
        
        if virtualObject.shouldUpdateAnchor {
            virtualObject.shouldUpdateAnchor = false
            addOrUpdataAnchor(for: virtualObject)
        }
    }
    
}

