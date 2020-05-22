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
    private var _lightView: UIView?

    var screenCenter: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }

    // MARK: - Singleton methods
    private lazy var configuation: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.isLightEstimationEnabled = true
        if #available(iOS 12.0, *) {
            config.environmentTexturing = .automatic
        }

        self.automaticallyUpdatesLighting = true

        // Debug option
        self.debugOptions = [.showFeaturePoints]

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

        // Take picture
        _lightView = UIView(frame: self.bounds)
        _lightView?.alpha = 0
        _lightView?.isHidden = true
        _lightView?.backgroundColor = UIColor.black
        self.addSubview(_lightView!)

    }

    // MARK: - AR Flow
    public func run() {
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

    public func takePicture() {
        self._lightView?.isHidden = false
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: { [weak self] in
            self?._lightView?.alpha = 1.0
        }, completion: { [weak self] (_: Bool) -> Void in
            self?._lightView?.alpha = 0.0
            self?._lightView?.isHidden = true

        })
        // Play the camera shutter system sound
        AudioServicesPlaySystemSound(1108)
        let photo = self.snapshot()
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
    }
}

extension ARGameView: ARSmartHitTest { }
