//
//  ARGameEngine+ARSessionDelegate.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/15.
//  Copyright © 2020 Jacob. All rights reserved.
//

import ARKit
import SceneKit

extension ARGameEngine: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {

    }

    // MARK: - AR Anchor state
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {

    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {

    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {

    }

    // MARK: - AR Session state
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {

    }

    func sessionWasInterrupted(_ session: ARSession) {

    }

    func sessionInterruptionEnded(_ session: ARSession) {

    }

    // MARK: - Error handler methods
    func session(_ session: ARSession, didFailWithError error: Error) {

    }

}
