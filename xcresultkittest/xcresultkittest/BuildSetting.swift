//
//  BuildSetting.swift
//  xcresultkittest
//
//  Created by David House on 9/11/22.
//

import Foundation

struct BuildSetting: Codable, Hashable {
    let name: String
    let value: String
}

extension BuildSetting {
    static let someSetting = BuildSetting(name: "someSetting", value: "someValue")
}

struct BuildAction: Codable, Hashable {
    let action: String
    let buildSettings: [String: String]
    let target: String
}
