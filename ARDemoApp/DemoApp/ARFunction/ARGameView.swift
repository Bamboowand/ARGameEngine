//
//  ARGameView.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/14.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

public class ARGameView: ARSCNView {
    private let _engine: ARGameEngine = ARGameEngine.shared
    
    var screenCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: - Singleton methods
    private lazy var configuation: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            config.environmentTexturing = .automatic
        }

        self.automaticallyUpdatesLighting = true
        return config
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    private func setup() {
        _engine.view = self
        _engine.scene = self.scene
        _engine.arSession = self.session
        self.session.delegate = _engine
        self.delegate = _engine
    }
    
    // MARK: - AR Flow
    public func run() {
        self.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        self.session.run(configuation, options: [])
    }
    
    public func restart() {
        self.session.run(configuation, options: [.resetTracking, .removeExistingAnchors])
    }
    
    public func pause() {
        self.session.pause()
    }
    
    // MARK: Scene controller
    public func placeModel(_ model: VirtualModelEntity, point: CGPoint? = nil) {
        _engine.placeModel(model, point: point)
    }
    
//    public func addModelEntity(_ model: VirtualModelEntity) {
//        _engine.placeModel(model)
//    }
    
    public func clearScene() {
        _engine.clearScene()
    }
    
}

extension ARGameView: ARSmartHitTest { }

