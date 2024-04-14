//
//  main.swift
//  ntfsmount
//
//  Created by Samuel He on 2023/9/30.
//

import Foundation
import CryptoKit

let fileManager = FileManager.default
var configEdit = false
let arguments = CommandLine.arguments
if arguments.count > 1 {
    if arguments[1] == "--config" {
        configEdit = true
        try? fileManager.removeItem(at: configFolderPath)
    }
}

if !fileManager.fileExists(atPath: configFolderPath.path()) || !fileManager.fileExists(atPath: configFilePath.path()) || configEdit {
    do {
        try runSetup()
    } catch {
        // Clean up the config folder in case of an error
        try fileManager.removeItem(at: configFolderPath)
        throw error
    }
}

let usingStoredPassword = PlistProcessor.parsePlistFile(at: configFilePath)!["StorePassword"] as! Bool

// Call the ntfsMount function to start the process
NTFSMount(usingStoredPassword: usingStoredPassword)
