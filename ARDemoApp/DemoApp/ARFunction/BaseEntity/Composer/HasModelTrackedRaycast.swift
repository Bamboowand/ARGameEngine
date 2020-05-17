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
    var anchor: ARAnchor? = nil
    var raycastQueue: ARRaycastQuery? = nil
    var raycast: ARTrackedRaycast? = nil
    var mostRecentInitialPlacementResult: ARRaycastResult? = nil
}

protocol HasModelTrackedRaycast: AnyObject {
    var trackedRaycastProperty: TrackedRaycastProperty { get set }
    func stopTrackedRaycast()
}

extension HasModelTrackedRaycast {
    var allowedAlignment: ARRaycastQuery.TargetAlignment {
        get {
            return trackedRaycastProperty.allowedAlignment
        }
        set {
            trackedRaycastProperty.allowedAlignment = newValue
        }
    }
    
    var shouldUpdateAnchor: Bool {
        get {
            return trackedRaycastProperty.shouldUpdateAnchor
        }
        set {
            trackedRaycastProperty.shouldUpdateAnchor = newValue
        }
    }
    
    var anchor: ARAnchor? {
        get {
            return trackedRaycastProperty.anchor
        }
        set {
            trackedRaycastProperty.anchor = newValue
        }
    }
    
    var raycastQueue: ARRaycastQuery? {
        get {
            return trackedRaycastProperty.raycastQueue
        }
        set {
            trackedRaycastProperty.raycastQueue = newValue
        }
    }
    
    var raycast: ARTrackedRaycast? {
        get {
            return trackedRaycastProperty.raycast
        }
        set {
            trackedRaycastProperty.raycast = newValue
        }
    }
    
    var mostRecentInitialPlacementResult: ARRaycastResult? {
        get {
            return trackedRaycastProperty.mostRecentInitialPlacementResult
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

