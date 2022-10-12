//
//  TestExecutor.swift
//  xcresultkittest
//
//  Created by David House on 10/8/22.
//

import Foundation
import XCResultKit

class TestExecutor {
    
    enum TestExecutorError: Error {
        case invalidProjectPath
        case noResultsFound
        case expectedFailure
    }
    
    let info: TestInfo
    var projectPath: URL?
    var settings: [BuildSetting] = []
    var results: XCResultFile?
    var summary: TestSummary?
    
    init(info: TestInfo) {
        self.info = info
    }
    
    func execute() async throws {
        // clone the repo
        try await clone()
        
        // switch to the specified branch
        try await checkoutBranch()
        
        // Get project path and settings
        try await gatherSettings()
        
        // run the tests
        try await executeTests()
        
        // load test results
        try await loadTestResults()

        // output the details
        try outputDetails()

        // check versus expected output
        try checkExpectedOutput()
    }
    
    func clone() async throws {
        print("--- cloning the repo from \(info.repoURL)")
        
        let arguments: [String] = [
            "-l",
            "-c",
            "git clone \(info.repoURL) ./tmp/\(info.name)"
        ]
        
        let results = xcresultkittest.execute(path: "/bin/sh", arguments)
        guard let resultData = results else {
            print("Error executing shell")
            return
        }
        
        let resultString = String(data: resultData, encoding: .utf8)
        print("got results: \(resultString ?? "")")
    }
    
    func checkoutBranch() async throws {
        print("--- checking out branch \(info.branch)")
        
        let arguments: [String] = [
            "-l",
            "-c",
            "cd ./tmp/\(info.name) && git checkout \(info.branch)"
        ]
        
        let results = xcresultkittest.execute(path: "/bin/sh", arguments)
        guard let resultData = results else {
            print("Error executing shell")
            return
        }
        
        let resultString = String(data: resultData, encoding: .utf8)
        print("got results: \(resultString ?? "")")
    }
    
    func gatherSettings() async throws {
        let current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let project = current
            .appendingPathComponent("tmp")
            .appendingPathComponent(info.name)
            .appendingPathComponent(info.project)
        self.projectPath = project
        
        let configuration = info.configuration ?? "Debug"

        print("Project is found here: \(project.path)")
        let xcb = XcodeBuild(project: project)
        do {
            let settings = try await xcb.buildSettings(scheme: info.scheme, configuration: configuration)
            print("Found \(settings.count) settings")
            self.settings = settings
        } catch {
            print("Got an error from settings...")
        }
    }
    
    func executeTests() async throws {
        guard let path = projectPath else {
            throw TestExecutorError.invalidProjectPath
        }
        
        let configuration = info.configuration ?? "Debug"
        // Remove the xcodeproj from the app, but append our build folder
        let ddPath = path.deletingLastPathComponent().appendingPathComponent("build")
        
        let xcb = XcodeBuild(project: path)
        do {
            try await xcb.test(scheme: info.scheme, configuration: configuration, platform: info.platform ?? "iOS Simulator,name=iPhone 13", derivedDataPath: ddPath.path)
        } catch {
            print("Error from test: \(error)")
        }

        print("--- test finished ---")
    }
    
    func loadTestResults() async throws {
        guard let path = projectPath else {
            throw TestExecutorError.invalidProjectPath
        }
        let ddPath = path.deletingLastPathComponent().appendingPathComponent("build")

        let derivedData = DerivedData()
        derivedData.debug = true
        derivedData.root = true
        derivedData.location = ddPath
        guard let resultFile = derivedData.recentResultFile() else {
            print("Unable to find XCResult file!")
            exit(1)
        }

        print("--- found at least one xcresult file")
        self.results = resultFile
    }
    
    func outputDetails() throws {
        
        let current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let details = current
            .appendingPathComponent("out")
            .appendingPathComponent("\(info.name).md")
        
        let detailsFile = try DetailsFile(path: details.path)
        detailsFile.writeLine("# \(info.name)")
        detailsFile.writeLine(" ")
        info.writeDetails(using: detailsFile)
        
        guard let results else {
            return
        }
        
        let testSummary = TestSummary()
        testSummary.gatherSummary(from: results)
        testSummary.writeDetails(using: detailsFile)
    }
    
    func checkExpectedOutput() throws {
        guard let results else {
            throw TestExecutorError.noResultsFound
        }
        
        let testSummary = TestSummary()
        testSummary.gatherSummary(from: results)
        summary = testSummary
        
        guard info.expectedSuccessfulTests == testSummary.successfulTests.count else {
            print("Expected \(info.expectedSuccessfulTests) successful tests, but found \(testSummary.successfulTests.count)!")
            throw TestExecutorError.expectedFailure
        }
        print("Expected \(info.expectedSuccessfulTests) successful tests, and found them!")
        
        guard info.expectedFailedTests == testSummary.failedTests.count else {
            print("Expected \(info.expectedFailedTests) failed tests, but found \(testSummary.failedTests.count)!")
            throw TestExecutorError.expectedFailure
        }
        print("Expected \(info.expectedFailedTests) failed tests, and found them!")

        guard info.expectedExpectedFailedTests == testSummary.expectedFailureTests.count else {
            print("Expected \(info.expectedExpectedFailedTests) expected failed tests, but found \(testSummary.expectedFailureTests.count)!")
            throw TestExecutorError.expectedFailure
        }
        print("Expected \(info.expectedFailedTests) expected failed tests, and found them!")
        
        guard info.expectedSkippedTests == testSummary.skippedTests.count else {
            print("Expected \(info.expectedSkippedTests) successful tests, but found \(testSummary.skippedTests.count)!")
            throw TestExecutorError.expectedFailure
        }
        print("Expected \(info.expectedSkippedTests) skipped tests, and found them!")
        

        var attachmentCount = 0
        for details in testSummary.testDetails {
            for asummary in details.activitySummaries {
                attachmentCount += asummary.attachments.count
            }
        }
        guard info.expectedAttachments == attachmentCount else {
            print("Expected \(info.expectedAttachments) attachments, but found \(attachmentCount)!")
            throw TestExecutorError.expectedFailure
        }
        print("Expected \(info.expectedAttachments) attachments, and found them!")
        
        print("Expected values match, overall test has passed!")
    }
}
