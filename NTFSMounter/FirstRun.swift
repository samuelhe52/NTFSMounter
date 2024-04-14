//
//  FirstRun.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/18.
//

import Foundation


func runSetup() throws {
    try fileManager.createDirectory(atPath: configFolderPath.path(), withIntermediateDirectories: false)
    fileManager.createFile(atPath: configFilePath.path(), contents: nil)
    print("Enter the your admin password to grant sudo privilege for ntfs-3g mounter.\nYou will only need to do this once and your password will be safely stored in your system's keychain;\nPress enter or type \"n\" to choose to input your password manually everytime you use this tool.")
    var qualified = false
    while qualified == false {
        print("Store your password? (y/n): ", terminator: "")
        let storePassword = readLine(strippingNewline: true)
        if storePassword == "y" {
            PlistProcessor.writePlist(toWrite: ["StorePassword": true], to: configFilePath)
            try storePasswordInKeychain()
            qualified.toggle()
        } else if storePassword == "n" {
            PlistProcessor.writePlist(toWrite: ["StorePassword": false], to: configFilePath)
            qualified.toggle()
        } else {
            print("Invalid option.")
        }
    }
}
