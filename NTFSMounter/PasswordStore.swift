//
//  PasswordStore.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/24.
//

import Foundation
import CryptoKit
import Security
import KeychainAccess

let keychain = Keychain(service: "com.samuelhe.ntfsmounter", accessGroup: "ntfsmounteraccess.com.samuelhe.ntfsmounter")

func receivePwdFromStdinAndCheckValidity() -> String? {
    var qualified = false
    var userPwd: String?
    
    while qualified == false {
        print("Enter you admin password: ", terminator: "")
        userPwd = readLine(strippingNewline: true)
        
        do {
            let _ = try runShellCommand("echo \(userPwd ?? "") | sudo -S cd /Users/$(whoami)")
            qualified.toggle()
        } catch {
            if error.localizedDescription.contains("1 incorrect password attempt") {
                print("Wrong Password. Try again.")
                continue
            }
            print("The password is invalid: \(error)")
            continue
        }
    }
    
    return userPwd
}


func storePasswordInKeychain() throws {
    let userPwd = receivePwdFromStdinAndCheckValidity()
    
    // Save the password in keychain
    try keychain.set(userPwd!, key: "UserPwdForNTFSMounter")
}


func retrieveUserPwd(usingStoredPassword: Bool) -> String? {
    var userPwd: String?
    
    if usingStoredPassword {
        if let keychainPwd = try? keychain.get("UserPwdForNTFSMounter") {
            userPwd = keychainPwd
        } else { // fallback to manually entry for pwd.
            print("An error occurred when trying to retrieve your password from keychain. Enter your password manually.")
            userPwd = receivePwdFromStdinAndCheckValidity()
        }
    } else {
        print("Enter you admin password to grant necessary privilieges.")
        userPwd = receivePwdFromStdinAndCheckValidity()
    }
    
    return userPwd
}
