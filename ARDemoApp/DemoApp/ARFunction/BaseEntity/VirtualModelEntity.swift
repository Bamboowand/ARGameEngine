//
//  VirtualEntity.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/14.
//  Copyright © 2020 Jacob. All rights reserved.
//

import Foundation
import GameplayKit
import ARKit
import SceneKit
import ModelIO

enum FileType {
    case usdz
    case dae
    case unknow
}

public class VirtualModelEntity: GKEntity, HasModelTrackedRaycast {
    let identity: String = ProcessInfo().globallyUniqueString

    var trackedRaycastProperty = TrackedRaycastProperty()

    let referenceNode: SCNReferenceNode
    var isLoading: Bool = false
    var photo: UIImage?

    var modelName: String {
        referenceNode.referenceURL.lastPathComponent.components(separatedBy: ".").dropLast().last!
    }

    var modelWidth: Float {
        let (min, max) = self.referenceNode.boundingBox
        let modelWidth = max.x - min.x
        return modelWidth
    }

    var modelDepth: Float {
        let (min, max) = self.referenceNode.boundingBox
        let modelDepth = max.z - min.z
        return modelDepth
    }

    var fileType: FileType {
        let typeStr = referenceNode.referenceURL.lastPathComponent.components(separatedBy: ".").last
        var type = FileType.unknow
        switch typeStr {
        case "usdz":
            type = .usdz
        case "dae":
            type = .dae
        default:
            type = .unknow
        }
        return type
    }

    var objectRotation: Float {
        get {
            referenceNode.childNodes.first!.eulerAngles.y
        }
        set (newValue) {
            referenceNode.childNodes.first!.eulerAngles.y = newValue
        }
    }

    // MARK: - Init methods
    init(url: URL) {
        guard let reference = SCNReferenceNode(url: url) else {
            fatalError("Error: Failed to load model URL \(url)")
        }
        self.referenceNode = reference
        super.init()
        self.referenceNode.name = "\(self.identity)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // swiftlint:disable line_length
        print("J_☠️ VirtualModelEntity release id = \(self.identity), model name: \(self.modelName), type: \(self.fileType)")
    }
}

public class VirtualModelEntityLoader {
    // MARK: - Load model methods
    static func loadAsync(name: String, in bundle: Bundle? = nil,
                          loadedHandle: @escaping (VirtualModelEntity) -> Void) {
        var loadUrl: URL
        if let bundle = bundle {
            guard let bundelURL = bundle.url(forResource: name, withExtension: "") else {
                fatalError("Error: Not find Name: \(name)")
            }
            loadUrl = bundelURL
        } else {
            guard let url = Bundle.main.url(forResource: name, withExtension: "") else {
                fatalError("Error: Not find Name: \(name)")
            }
            loadUrl = url
        }
        VirtualModelEntityLoader.loadAsync(url: loadUrl, loadedHandle: loadedHandle)
    }

    static func loadAsync(url: URL, loadedHandle: @escaping (VirtualModelEntity) -> Void) {
        let entity = VirtualModelEntity(url: url)
        DispatchQueue.global(qos: .utility).async {
            entity.isLoading = true
            let startTime = CFAbsoluteTimeGetCurrent()
            entity.referenceNode.load()
            entity.isLoading = false
            entity.referenceNode.categoryBitMask = CategoryBitMask.categoryToSelect.rawValue
            entity.referenceNode.enumerateChildNodes { (node, _) in
                node.categoryBitMask = CategoryBitMask.categoryToSelect.rawValue
            }

            let render = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
            do {
                render.scene = try SCNScene(url: entity.referenceNode.referenceURL, options: nil)
                let renderTime = TimeInterval(0)
                let photoSize = CGSize(width: 100.0, height: 100.0)
                entity.photo = render.snapshot(atTime: renderTime, with: photoSize, antialiasingMode: .multisampling4X)
            } catch {
                fatalError("Failed to load SCNScene from \(entity.modelName) referenceURL")
            }
            DispatchQueue.main.async {
                loadedHandle(entity)
            }
//            entity.referenceNode.unload()
            let endTime = CFAbsoluteTimeGetCurrent()
            debugPrint("Virtual model load \(entity.modelName) in \((endTime - startTime) * 1000) millisecond")
        }
    }
}

// MARK: GKEntity methods
extension VirtualModelEntity {

    public override func update(deltaTime seconds: TimeInterval) {

    }

}
