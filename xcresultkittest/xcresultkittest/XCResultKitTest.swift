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
        
        print("--- XCResultKit Test Harness ---")
        
        let current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let exampleproject = current.appendingPathComponent("examples")
            .appendingPathComponent("multiplatform")
            .appendingPathComponent("multiplatform.xcodeproj")
            
        print("Project is found here: \(exampleproject)")
        let xcb = XcodeBuild(project: exampleproject)
        var ddPath: String?
        do {
            let settings = try await xcb.buildSettings(scheme: "multiplatform", configuration: "Debug")
            print("Found \(settings.count) settings")
            ddPath = settings.filter { $0.name == "BUILD_DIR" }.first?.value
        } catch {
            print("Got an error from settings...")
        }
            
        print("--- got the settings ---")
        
        do {
            try await xcb.clean(scheme: "multiplatform", configuration: "Debug")
        } catch {
            print("Error from clean: \(error)")
        }
        
        print("--- clean finished ---")
        
        do {
            try await xcb.test(scheme: "multiplatform", configuration: "Debug", platform: "iOS Simulator,name=iPhone 13")
        } catch {
            print("Error from test: \(error)")
        }
        
        print("--- test finished ---")
        
        
        guard let derivedDataPath = ddPath else {
            print("Unable to find dd path")
            return
        }
        
        let rootPath = URL(fileURLWithPath: derivedDataPath).deletingLastPathComponent().deletingLastPathComponent()
        
        let derivedData = DerivedData()
        derivedData.debug = true
        derivedData.root = true
        derivedData.location = rootPath
        guard let resultKit = derivedData.recentResultFile() else {
            print("Unable to find XCResult file!")
            exit(1)
        }

        print("--- found at least one xcresult file")

        guard let invocationRecord = resultKit.getInvocationRecord() else {
            print("Unable to find invocation record in XCResult file!")
            exit(1)
        }

        var testRunSummaries: [ActionTestPlanRunSummary] = []
        for action in invocationRecord.actions {
            if let testRef = action.actionResult.testsRef {
                if let runSummaries = resultKit.getTestPlanRunSummaries(id: testRef.id) {
                    for summary in runSummaries.summaries {
                        testRunSummaries.append(summary)
                    }
                }
            }
        }

        print("--- found \(testRunSummaries.count) test run summaries")
        
        let tests = gatherTests(summaries: testRunSummaries)
        print("--- found \(tests.count) tests!")
        
        for test in tests {
            print("-> \(test.summaryRef?.id ?? "")")
        }
    }
    
    static func gatherTests(summaries: [ActionTestPlanRunSummary]) -> [ActionTestMetadata] {
        var foundTests = [ActionTestMetadata]()
        for summary in summaries {
            for testableSummary in summary.testableSummaries {
                print("URL: \(testableSummary.identifierURL ?? "")")
                for testGroup in testableSummary.tests {
                    foundTests += gatherTests(group: testGroup)
                }
            }
        }
        return foundTests
    }

    static func gatherTests(group: ActionTestSummaryGroup) -> [ActionTestMetadata] {
        var tests = group.subtests
        for test in group.subtests {
            tests.append(test)
        }
        return tests
    }
}
