//
//  main.swift
//  xcresultkittest
//
//  Created by David House on 8/27/22.
//

import Foundation
import XCResultKit

// Build the multiplatform example app

// Now grab the results and print out the responses

@main
struct MainApp {
    static func main() async {
        
        // Need to create /out and /tmp folders
        do {
            try await emptyFolder(named: "tmp")
            try await createFolder(named: "tmp")
            try await emptyFolder(named: "out")
            try await createFolder(named: "out")
        } catch {
            print("Error cleaning up tmp folder")
            return
        }
        
        print("--- XCResultKit Test Harness ---")
        
        let tests = [
            TestInfo(name: "stampede-app",
                     repoURL: URL(string: "git@github.com:davidahouse/stampede-app.git")!,
                     branch: "main",
                     project: "Stampede/Stampede.xcodeproj", scheme: "Stampede Fixtures",
                     configuration: nil,
                     platform: "iOS Simulator,name=iPhone 13",
                     expectedSuccessfulTests: 108,
                     expectedFailedTests: 0,
                     expectedSkippedTests: 0,
                     expectedExpectedFailedTests: 0,
                     expectedAttachments: 212
                    ),
            TestInfo(name: "XCTestExamples",
                     repoURL: URL(string: "git@github.com:davidahouse/XCTestExamples.git")!,
                     branch: "main",
                     project: "XCTestExamples/XCTestExamples.xcodeproj",
                     scheme: "XCTestExamples",
                     configuration: nil,
                     platform: "iOS Simulator,name=iPhone 13",
                     expectedSuccessfulTests: 8,
                     expectedFailedTests: 2,
                     expectedSkippedTests: 1,
                     expectedExpectedFailedTests: 1,
                     expectedAttachments: 4
                    )
        ]
        
        print("--- Found \(tests.count) tests to execute ---")
        
        for test in tests {
            
            let executor = TestExecutor(info: test)
            do {
                try await executor.execute()
            } catch {
                print("Error executing test: \(error)")
            }
        }
    }
    
    static func emptyFolder(named: String) async throws {
        print("--- emptying out the \(named) folder")
        
        let arguments: [String] = [
            "-l",
            "-c",
            "rm -rf ./\(named)/"
        ]
        
        _ = xcresultkittest.execute(path: "/bin/sh", arguments)
    }
    
    static func createFolder(named: String) async throws {
        print("--- emptying out the \(named) folder")
        
        let arguments: [String] = [
            "-l",
            "-c",
            "mkdir \(named)"
        ]
        
        _ = xcresultkittest.execute(path: "/bin/sh", arguments)
    }

}
