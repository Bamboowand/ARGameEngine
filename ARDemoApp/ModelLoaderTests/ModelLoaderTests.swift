//
//  ModelLoaderTests.swift
//  ModelLoaderTests
//
//  Created by ChenWei on 2020/5/15.
//  Copyright © 2020 Jacob. All rights reserved.
//

import XCTest
@testable import DemoApp

class ModelLoaderTests: XCTestCase {
    
    var entity: VirtualModelEntity? = nil
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        entity = nil
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadEntity() throws {
        guard let url = Bundle.main.url(forResource: "t_rex", withExtension: "usdz") else {
            fatalError("Error: Fail url")
        }
        VirtualModelEntity.loadAsync(url: url) { [weak self] virtual in
            self?.entity = virtual
            XCTAssertNil(self?.entity, "Error: Failed to load model")
        }
        
        WebInteraction.downloadFile(url: URL(string: "https://bamboowand.github.io/retrotv.usdz")!) { fileURL in
            
        }
        
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
