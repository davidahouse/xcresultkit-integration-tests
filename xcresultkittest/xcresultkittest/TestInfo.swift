//
//  TestInfo.swift
//  xcresultkittest
//
//  Created by David House on 10/8/22.
//

import Foundation

struct TestInfo {
    let name: String
    let repoURL: URL
    let branch: String
    
    let project: String
    let scheme: String
    let configuration: String?
    let platform: String?
    
    let expectedSuccessfulTests: Int
    let expectedFailedTests: Int
    let expectedSkippedTests: Int
    
    func writeDetails(using file: DetailsFile) {
        file.writeLine(" Repo URL: \(repoURL)")
        file.writeLine(" Branch: \(branch)")
        file.writeLine(" Project: \(project)")
        file.writeLine(" Scheme: \(scheme)")
        file.writeLine(" Configuration: \(String(describing: configuration))")
        file.writeLine(" Platform: \(String(describing: platform))")
        file.writeLine(" Expected Successful Tests: \(expectedSuccessfulTests)")
        file.writeLine(" Expected Failed Tests: \(expectedFailedTests)")
        file.writeLine(" Expected Skipped Tests: \(expectedSkippedTests)")
        file.writeLine(" ")
    }
}
