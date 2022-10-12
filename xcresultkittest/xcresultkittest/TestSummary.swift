//
//  TestSummary.swift
//  xcresultkittest
//
//  Created by David House on 10/9/22.
//

import Foundation
import XCResultKit

class TestSummary {
    
    var successfulTests: [ActionTestMetadata] = []
    var failedTests: [ActionTestMetadata] = []
    var skippedTests: [ActionTestMetadata] = []
    var expectedFailureTests: [ActionTestMetadata] = []
    var failureMessages: [TestFailureIssueSummary] = []
    var testDetails: [ActionTestSummary] = []
    
    func gatherSummary(from result: XCResultFile) {
        
        guard let invocationRecord = result.getInvocationRecord() else {
            print("Unable to find invocation record in XCResult file!")
            return
        }

        // Gather up the summaries. There can be more than one of these
        // in the results since you can have multiple test plans.
        var testRunSummaries: [ActionTestPlanRunSummary] = []
        for action in invocationRecord.actions {
            if let testRef = action.actionResult.testsRef {
                if let runSummaries = result.getTestPlanRunSummaries(id: testRef.id) {
                    for summary in runSummaries.summaries {
                        testRunSummaries.append(summary)
                    }
                }
            }
        }

        // Now we can collect the test results
        let tests = gatherTests(summaries: testRunSummaries)

        for test in tests {
            print("-> \(test.summaryRef?.id ?? "") \(String(describing: test.name)) \(String(describing: test.identifier)) \(test.testStatus)")
            print("  \(String(describing: test.activitySummariesCount)) \(String(describing: test.failureSummariesCount)) \(String(describing: test.performanceMetricsCount))")
            if let testID = test.summaryRef?.id {
                if let testSummary = result.getActionTestSummary(id: testID) {
                    testDetails.append(testSummary)
                }
            }
        }
        
        successfulTests = tests.filter { $0.testStatus == "Success" }
        failedTests = tests.filter { $0.testStatus == "Failure" }
        skippedTests = tests.filter { $0.testStatus == "Skipped" }
        expectedFailureTests = tests.filter { $0.testStatus == "Expected Failure"}
        
        failureMessages = invocationRecord.issues.testFailureSummaries
    }
    
    private func gatherTests(summaries: [ActionTestPlanRunSummary]) -> [ActionTestMetadata] {
        var foundTests = [ActionTestMetadata]()
        for summary in summaries {
            for testableSummary in summary.testableSummaries {
                for testGroup in testableSummary.tests {
                    foundTests += gatherTests(group: testGroup)
                }
            }
        }
        return foundTests
    }

    private func gatherTests(group: ActionTestSummaryGroup) -> [ActionTestMetadata] {
        
        var tests = group.subtests
        
        for subgroup in group.subtestGroups {
            let subtests = gatherTests(group: subgroup)
            tests += subtests
        }
        
        return tests
    }
    
    func writeDetails(using file: DetailsFile) {
        
        file.writeLine("## Successful Tests")
        file.writeLine(" ")
        for test in successfulTests {
            file.writeLine("- \(String(describing: test.identifier)) \(test.duration ?? 0)s")
        }

        file.writeLine(" ")
        file.writeLine("## Failed Tests")
        file.writeLine(" ")
        for test in failedTests {
            file.writeLine("- \(String(describing: test.identifier)) \(test.duration ?? 0)s")
        }

        file.writeLine(" ")
        file.writeLine("## Expected Failure Tests")
        file.writeLine(" ")
        for test in expectedFailureTests {
            file.writeLine("- \(String(describing: test.identifier)) \(test.duration ?? 0)s")
        }

        file.writeLine(" ")
        file.writeLine("## Skipped Tests")
        file.writeLine(" ")
        for test in skippedTests {
            file.writeLine("- \(String(describing: test.identifier)) \(test.duration ?? 0)s")
        }
        
        file.writeLine(" ")
        file.writeLine("## Failure Messages")
        file.writeLine(" ")
        for issue in failureMessages {
            file.writeLine("- \(issue.testCaseName) \(issue.issueType) \(issue.message)")
        }
    }
}

