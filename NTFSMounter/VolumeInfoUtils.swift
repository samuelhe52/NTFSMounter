//
//  VolumeInfoUtils.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/18.
//

import Foundation

func unmountVolumeWithPath(path: String) {
    let pathURL = URL(filePath: path)
    fileManager.unmountVolume(at: pathURL, completionHandler: {(result: Error?) -> Void in
        if let error = result {
            print("Failed to unmount due to an error: \(error)")
        }
    })
}

func fetchVolumeInfo() -> [String: [String: String]] {
    let resourceKeys: [URLResourceKey] = [.volumeNameKey, .volumeLocalizedFormatDescriptionKey, .volumeTotalCapacityKey, .volumeIdentifierKey, .volumeAvailableCapacityKey]
    
    var volumeInfo: [String: [String: String]] = [:]

    if let volumes = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: resourceKeys, options: .skipHiddenVolumes) {
        for volume in volumes {
            if let resources = try? volume.resourceValues(forKeys: Set(resourceKeys)),
               let name = resources.volumeName,
               let format = resources.volumeLocalizedFormatDescription,
               let totalSize = resources.volumeTotalCapacity,
               let availableSize = resources.volumeAvailableCapacity {
                volumeInfo.updateValue(["format": format, "totalsize": String(format: "%.2f", Double(totalSize) / 1000000000) + " GB", "availablesize": String(format: "%.2f", Double(availableSize) / 1000000000) + " GB"], forKey: name)
                }
            }
        }
    return volumeInfo
}

func fetchNTFSDisks() -> [[String: String]] {
    var NTFSDisks: [[String: String]] = []
    
    if let generalInfo = (try? runShellCommandWithDataOutput("diskutil list -plist")) {
        let diskUtilGeneral = PlistProcessor.parsePlist(plistData: generalInfo)!
        let allDisksAndPartitions = diskUtilGeneral["AllDisksAndPartitions"]! as! NSArray
        for disk in allDisksAndPartitions {
            let partitions = (disk as! NSDictionary)["Partitions"]!
            for diskPartition in (partitions as! NSArray) {
                let partitionInfo = diskPartition as! NSDictionary
                let volumeName = partitionInfo["VolumeName"] as? String
                let volumeIdentifier = partitionInfo["DeviceIdentifier"]! as! String
                let volumeType = partitionInfo["Content"]! as! String
                
                if volumeType == "Microsoft Basic Data" || volumeType == "Windows_NTFS" {
                    NTFSDisks.append(["Name": volumeName ?? "", "Identifier": volumeIdentifier, "Type": volumeType])
                }
            }
        }
    }
    
    for diskPartition in NTFSDisks {
        let identifier = diskPartition["Identifier"]!
        if let thoroughInfo = (try? runShellCommandWithDataOutput("diskutil info -plist \(identifier)")) {
            let diskUtilThorough = PlistProcessor.parsePlist(plistData: thoroughInfo)!
            let fsType = diskUtilThorough["FilesystemName"]! as! NSString
            if fsType != "NTFS" {
                NTFSDisks.remove(at: NTFSDisks.firstIndex(of: diskPartition)!)
            }
        }
    }
    
    return NTFSDisks
}
