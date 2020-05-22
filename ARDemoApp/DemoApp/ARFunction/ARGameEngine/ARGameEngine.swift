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

enum CategoryBitMask: Int {
    case categoryToSelect = 2        // 010
    case otherCategoryToSelect = 4   // 100
    // you can add more bit masks below . . .
}

class ARGameEngine: NSObject {
    public let focusNode = FocusSquare()
    weak var view: ARGameView? {
        didSet {
            self.focusNode.viewDelegate = view
            self.scene?.rootNode.addChildNode(self.focusNode)
        }
    }
    weak var scene: SCNScene?
    weak var arSession: ARSession?
    // MARK: - Property storge
    private(set) var modelEntitys = [VirtualModelEntity]()
    private let _updateQueue = DispatchQueue(label: "com.argame_engine_j.serial_scenekit_queue")

    // MARK: - Singleton init
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
        modelEntitys.append(newModel)
    }

    internal func clearScene() {
        // Reverse the indices so we don't trample over indices as objects are removed.
        for index in modelEntitys.indices.reversed() {
            removeModelEntity(at: index)
        }
    }

    internal func removeModelEntity(at index: Int) {
        guard modelEntitys.indices.contains(index) else { return }

        // Stop the object's tracked ray cast.
        modelEntitys[index].stopTrackedRaycast()

        // Remove the visual node from the scene graph.
        if let anchor = modelEntitys[index].anchor {
            arSession?.remove(anchor: anchor)
            modelEntitys[index].anchor = nil
        }
        modelEntitys[index].raycastQueue = nil
        modelEntitys[index].referenceNode.removeFromParentNode()

        // Recoup resources allocated by the object.
        modelEntitys[index].referenceNode.unload()
        modelEntitys.remove(at: index)
    }

    // MARK: - Place model flow
    private func setObjectTransform(of virtualObject: VirtualModelEntity, with result: ARRaycastResult) {
        virtualObject.referenceNode.simdWorldPosition = result.worldTransform.translation
        virtualObject.referenceNode.simdWorldOrientation = result.worldTransform.orientation
    }

    internal func placeModel(_ newModel: VirtualModelEntity, point: CGPoint? = nil) {
        if modelEntitys.contains(where: { $0.identity == newModel.identity }) && !newModel.shouldUpdateAnchor {
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

            self?.setObjectTransform(of: newModel, with: result)
            self?.scene?.rootNode.addChildNode(newModel.referenceNode)
            self?.addModel(newModel)

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
                                                       withInitialResult initialResult: ARRaycastResult? = nil)
        -> ARTrackedRaycast? {
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
