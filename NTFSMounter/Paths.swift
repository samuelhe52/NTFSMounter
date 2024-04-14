//
//  Paths.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/18.
//

import Foundation

let homeDirectoryPath = fileManager.homeDirectoryForCurrentUser
let configFolderPath = homeDirectoryPath.appending(path: ".config/NTFSMounter")

let configFilePath = configFolderPath.appending(path: "NTFSMounter.plist")
