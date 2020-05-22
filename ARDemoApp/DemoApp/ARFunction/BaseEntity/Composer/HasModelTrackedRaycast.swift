//
//  HasModelTrackedRaycast.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/14.
//  Copyright © 2020 Jacob. All rights reserved.
//
import ARKit

struct TrackedRaycastProperty {
    var allowedAlignment: ARRaycastQuery.TargetAlignment = .any
    var shouldUpdateAnchor: Bool = false
    var anchor: ARAnchor?
    var raycastQueue: ARRaycastQuery?
    var raycast: ARTrackedRaycast?
    var mostRecentInitialPlacementResult: ARRaycastResult?
}

protocol HasModelTrackedRaycast: AnyObject {
    var trackedRaycastProperty: TrackedRaycastProperty { get set }
    func stopTrackedRaycast()
}

extension HasModelTrackedRaycast {
    var allowedAlignment: ARRaycastQuery.TargetAlignment {
        get {
            trackedRaycastProperty.allowedAlignment
        }
        set {
            trackedRaycastProperty.allowedAlignment = newValue
        }
    }

    var shouldUpdateAnchor: Bool {
        get {
            trackedRaycastProperty.shouldUpdateAnchor
        }
        set {
            trackedRaycastProperty.shouldUpdateAnchor = newValue
        }
    }

    var anchor: ARAnchor? {
        get {
            trackedRaycastProperty.anchor
        }
        set {
            trackedRaycastProperty.anchor = newValue
        }
    }

    var raycastQueue: ARRaycastQuery? {
        get {
            trackedRaycastProperty.raycastQueue
        }
        set {
            trackedRaycastProperty.raycastQueue = newValue
        }
    }

    var raycast: ARTrackedRaycast? {
        get {
            trackedRaycastProperty.raycast
        }
        set {
            trackedRaycastProperty.raycast = newValue
        }
    }

    var mostRecentInitialPlacementResult: ARRaycastResult? {
        get {
            trackedRaycastProperty.mostRecentInitialPlacementResult
        }
        set {
            trackedRaycastProperty.mostRecentInitialPlacementResult = newValue
        }
    }

    func stopTrackedRaycast() {
        raycast?.stopTracking()
        raycast = nil
    }
}
