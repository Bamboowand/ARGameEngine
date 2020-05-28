//
//  LocalLoader.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/27.
//  Copyright © 2020 Jacob. All rights reserved.
//

import Foundation
import UIKit

struct ModelLoadViewModel {
    let modelName: String
    var photo: UIImage?
    var isLoading = false
    var model: VirtualModelEntity?
    var areaSize: CGSize?
}

class LocalLoader: NSObject {

    typealias LoadCallback = ([ModelLoadViewModel]) -> Void

    // MARK: - Property
    private let asset = "Resources.scnassets"
    lazy var loadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 20
        print("Create Oper")
        return queue
    }()
    var loadModel: LoadCallback?
    private(set) var models = [ModelLoadViewModel]() {
        didSet {
            self.loadModel?(self.models)
        }
    }

    // MARK: - Singleton init
    struct Static {
        internal static var instance: LocalLoader?
    }

    public class var shared: LocalLoader {
        if Static.instance == nil {
            Static.instance = LocalLoader()
        }
        return Static.instance!
    }

    private override init() {
        super.init()
        print("J_🔧 LocalLoader init")
    }

    func dispose() {
        LocalLoader.Static.instance = nil
        print("J_🗡 LocalLoader disposed singleton instance")
    }

    deinit {
        print("J_☠️ LocalLoader release")
    }
    // MARK: -

    public func loadLocal() {
        guard let path = Bundle.main.path(forResource: asset, ofType: nil) else {
            fatalError("Error: Not fount \(asset)")
        }

        do {
            let modelList = try FileManager.default.contentsOfDirectory(atPath: path)
            for fileName in modelList {
                print("\(fileName)")
                var model = ModelLoadViewModel(modelName: fileName)
                model.isLoading = true
                VirtualModelEntityLoader.loadAsync(name: fileName, in: Bundle(path: path)) { entity in
                    OperationQueue.main.addOperation { [weak self] in
                        guard let `self` = self else { return }
                        var newModel = ModelLoadViewModel(modelName: fileName)
                        newModel.photo = entity.photo
                        newModel.model = entity
                        newModel.isLoading = false
                        newModel.areaSize = CGSize(width: CGFloat(entity.modelWidth),
                                                   height: CGFloat(entity.modelDepth))
                        self.models.append(newModel)

                        self.loadModel?(self.models)
                    }
                }
            }
        } catch {
            fatalError("Error: " + asset + "not found")
        }
    }
}
