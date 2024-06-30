//
//  NTFSMount.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/24.
//

import Foundation

func NTFSMount(usingStoredPassword: Bool) {
    // Fetch information about currently mounted volumes
    let mountedDisks = fetchVolumeInfo()
    var counter = 0
    
    let NTFSDisks = fetchNTFSDisks()
    let userPwd = retrieveUserPwd(usingStoredPassword: usingStoredPassword)!
    
    
    // Loop through each NTFS disk found
    for disk in NTFSDisks {
        let diskName = disk["Name"]!
        let diskIdentifier = disk["Identifier"]!
        var command = "echo \(userPwd) | sudo -S /opt/homebrew/bin/ntfs-3g /dev/\(diskIdentifier) /Volumes/NTFS/\(diskName) -o volname=\(diskName)_macFUSE -o local -o allow_other -o auto_xattr -o auto_cache"

        
        func remount(commandForRemount: String) {
            // Attempt to remount the volume using ntfs-3g
            do {
                let _ = try runShellCommand(commandForRemount)
                counter += 1
                print("Volume \(diskName) mounted as a macFUSE Volume\n")
            } catch {
                print("Volume \(diskName) failed to mount due to an error: \(error)")
                let _ = try? runShellCommandDisplay("diskutil mount \(diskIdentifier)")
            }
        }

        print("NTFS Volume found: " + diskName)
        
        // Check if the volume is already mounted as a macFUSE Volume
        if mountedDisks.keys.contains("\(diskName)_macFUSE") == true && mountedDisks["\(diskName)_macFUSE"]!["format"] == "NTFS-3g (macFUSE)" {
            print("Volume \(diskName) is already mounted as a macFUSE Volume\n")
        } else if mountedDisks.keys.contains(diskName) == false {
            // Volume is not mounted, attempt to mount it with remount function
            print("\(diskName) on \(diskIdentifier) is already unmounted")
            remount(commandForRemount: command)
        } else {
            // Volume is mounted, unmount and then remount
            let _ = try? runShellCommand("diskutil unmount \(diskIdentifier)")
            print("\(diskName) on \(diskIdentifier) unmounted\n")
            remount(commandForRemount: command)
        }
    }
    
    if counter == 0 {
        print("No NTFS volume mounted.")
    } else {
        print("\(counter) Volume(s) mounted")
    }
}
