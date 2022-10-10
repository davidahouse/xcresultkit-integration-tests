//
//  multiplatformTests.swift
//  multiplatformTests
//
//  Created by David House on 8/27/22.
//

import XCTest

final class multiplatformTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExampleSuccess() throws {
        XCTAssertTrue(true, "this test is successful")
    }
    
    func testExampleFailed() throws {
        XCTAssertTrue(false, "this test is supposed to fail")
    }
    
    func testExampleSkipped() throws {
        XCTSkip("This test is skipped on purpose so we can capture at least one skipped test")
    }
    
    func testExpectedFailure() throws {
        let thingThatFails: Bool = false
        XCTExpectFailure("Working on a fix for this problem.")
        XCTAssertTrue(thingThatFails, "This is not working right now.")
    }
    
    func testExpectedFailureFails() throws {
        let thingThatFails: Bool = true
        XCTExpectFailure("Working on a fix for this problem.")
        XCTAssertTrue(thingThatFails, "This is not working right now.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            var total = 0
            for i in 1...10 {
                total += i
            }
            XCTAssertGreaterThan(total, 0)
        }
    }

}
