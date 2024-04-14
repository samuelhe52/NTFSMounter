//
//  PlistProcessor.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/18.
//

import Foundation

struct PlistProcessor {
    // Function to parse plist
    static func parsePlist(plistData: Data) -> NSDictionary? {
        // Deserialize the plist data
        let plistData = try? PropertyListSerialization.propertyList(from: plistData, options: .mutableContainers, format: nil)
        
        // Use the deserialized plist data
        if let dict = plistData as? NSDictionary {
            // If the plist root is a dictionary
            return dict
        } else {
            return nil
        }
    }

    static func parsePlistFile(at filePath: URL) -> NSDictionary? {
        if let DataToParse = fileManager.contents(atPath: filePath.path()) {
            return parsePlist(plistData: DataToParse)
        } else {
            return nil
        }
    }

    static func writePlist<T>(toWrite: Dictionary<String, T>, to filePath: URL) where T: Encodable {
        if fileManager.fileExists(atPath: filePath.path()) == false {
            fileManager.createFile(atPath: filePath.path(), contents: nil)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        if let encodedData = try? propertyListEncoder.encode(toWrite) {
            try? encodedData.write(to: filePath)
        }
    }
}
