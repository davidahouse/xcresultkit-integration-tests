//
//  Execute.swift
//  xcresultkittest
//
//  Created by David House on 9/11/22.
//

import Foundation

@discardableResult
func execute(path: String, _ arguments: [String]) -> Data? {
    autoreleasepool {
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        
        var resultData: Data?
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        resultData = pipe.fileHandleForReading.readDataToEndOfFile()
        
        task.waitUntilExit()

        //let taskSucceeded = task.terminationStatus == EXIT_SUCCESS
        return resultData
    }
}
