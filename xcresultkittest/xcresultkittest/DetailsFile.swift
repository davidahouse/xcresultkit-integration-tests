//
//  DetailsFile.swift
//  xcresultkittest
//
//  Created by David House on 10/9/22.
//

import Foundation

class DetailsFile {
    
    enum DetailsFileError: Error {
        case initFailure
    }
    
    let fileHandle: FileHandle
    
    init(path: String) throws {
        FileManager.default.createFile(atPath: path, contents: nil)
        guard let fileHandle = FileHandle(forWritingAtPath: path) else {
            throw DetailsFileError.initFailure
        }
        self.fileHandle = fileHandle
        try fileHandle.seekToEnd()
    }
    
    deinit {
        do {
            try fileHandle.close()
        } catch {
            //
        }
    }
    
    func writeLine(_ line: String) {
        let fullLine = "\(line)\n"
        if let fileLineData = fullLine.data(using: .utf8) {
            fileHandle.write(fileLineData)
        }
    }
}
