//
//  NTFSMounterError.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/18.
//

import Foundation

enum ShellCommandError: Error {
    case RunCommandFailed(Int32)
}

extension ShellCommandError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .RunCommandFailed(let returnCode):
            return NSLocalizedString("Run command failed with non-zero exit code: \(returnCode)", comment: "")
        }
    }
}

struct KeyStoreError: Error, CustomStringConvertible {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var description: String {
        return message
    }
}

extension OSStatus {
    
    /// A human readable message for the status.
    var message: String {
        return (SecCopyErrorMessageString(self, nil) as String?) ?? String(self)
    }
}
