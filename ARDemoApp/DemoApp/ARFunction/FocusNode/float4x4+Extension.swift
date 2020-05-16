//
//  float4x4+Extension.swift
//  FocusNode
//
//  Created by Max Cobb on 12/5/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import SceneKit

internal extension float4x4 {
	/**
	Factors out the orientation component of the transform.
	*/
	var orientation: simd_quatf {
		return simd_quaternion(self)
	}
}
