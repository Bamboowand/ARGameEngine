//
//  HasModelTrackedRaycast.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/14.
//  Copyright © 2020 Jacob. All rights reserved.
//
import ARKit

struct TrackedRaycastProperty {
    var anchor: ARAnchor? = nil
    var raycastQueue: ARRaycastQuery? = nil
    var raycast: ARTrackedRaycast? = nil
}

protocol HasModelTrackedRaycast: AnyObject {
    var trackedRaycastProperty: TrackedRaycastProperty { get set }
    func stopTrackedRaycast()
}

extension HasModelTrackedRaycast {
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
    
    func stopTrackedRaycast() {
        raycast?.stopTracking()
        raycast = nil
    }
}

