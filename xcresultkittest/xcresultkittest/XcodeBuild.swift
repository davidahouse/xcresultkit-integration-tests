//
//  XcodeBuild.swift
//  xcresultkittest
//
//  Created by David House on 9/11/22.
//

import Foundation

class XcodeBuild {
    
    enum BuildType {
        case project(path: URL)
        case workspace(path: URL)
        
        func xcodebuildParam() -> String {
            switch self {
            case .project(let url):
                return "-project \(url.path)"
            case .workspace(let url):
                return "-workspace \(url.path)"
            }
        }
    }
    
    enum BuildResult {
        case success
        case failure
    }
    
    let buildType: BuildType
    
    init(project: URL) {
        buildType = .project(path: project)
    }
    
    init(workspace: URL) {
        buildType = .workspace(path: workspace)
    }
    

    func buildSettings(scheme: String, configuration: String) async throws -> [BuildSetting] {
        
        let arguments: [String] = [
            "-l",
            "-c",
            "xcodebuild \(buildType.xcodebuildParam()) -scheme \(scheme) -configuration \(configuration) -showBuildSettings -json"
        ]
        
        let results = execute(path: "/bin/sh", arguments)
        guard let resultData = results else {
            print("Error executing xcodebuild")
            return []
        }
        
        let resultString = String(data: resultData, encoding: .utf8)
        print("got results: \(resultString ?? "")")
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode([BuildAction].self, from: resultData)
            if decoded.count > 0 {
                var settings = [BuildSetting]()
                for (key, value) in decoded[0].buildSettings {
                    settings.append(BuildSetting(name: key, value: value))
                }
                return settings
            } else {
                print("No results found")
            }
        } catch {
            print("Error decoding: \(error)")
        }
        
//        task.launchPath = "/bin/sh"
//        task.arguments = ["-l", "-c", "xcodebuild \(self.project.value.xcodebuildParam()) -scheme \"\(scheme)\" -configuration \"\(configuration)\" -showBuildSettings -json"]

     
        return []
    }
    
    func clean(scheme: String, configuration: String) async throws {
        
        let arguments: [String] = [
            "-l",
            "-c",
            "xcodebuild \(buildType.xcodebuildParam()) -scheme \(scheme) -configuration \(configuration) clean"
        ]
        
        let results = execute(path: "/bin/sh", arguments)
        guard let resultData = results else {
            print("Error executing xcodebuild")
            return
        }
        
        let resultString = String(data: resultData, encoding: .utf8)
        print("got results: \(resultString ?? "")")
    }
    
    func test(scheme: String, configuration: String, platform: String, derivedDataPath: String?) async throws {

        let ddPath: String = {
            if let path = derivedDataPath {
                return "-derivedDataPath \"\(path)\""
            } else {
                return ""
            }
        }()
        
        let arguments: [String] = [
            "-l",
            "-c",
            "xcodebuild \(buildType.xcodebuildParam()) -scheme \"\(scheme)\" -configuration \"\(configuration)\" -destination \"platform=\(platform)\" \(ddPath) test"
        ]
        
        let results = execute(path: "/bin/sh", arguments)
        guard let resultData = results else {
            print("Error executing xcodebuild")
            return
        }
        
        let resultString = String(data: resultData, encoding: .utf8)
        print("got results: \(resultString ?? "")")
    }

}
