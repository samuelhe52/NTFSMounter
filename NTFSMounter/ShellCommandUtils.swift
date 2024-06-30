//
//  ShellCommandUtils.swift
//  ntfsmounter
//
//  Created by Samuel He on 2024/3/18.
//

import Foundation

/**
 * - parameter command: A String containing the command you want to run; Seperating the command isn't necessary.
 */
func runShellCommandWithDataOutputDisplay(_ command: String) throws -> Data? {
    let shellCommandProcess = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    let safeErrorMessages = ["Password:\n",
                             "Password:",
                             "Password:The disk contains an unclean file system (0, 0).\nThe file system wasn\'t safely closed on Windows. Fixing.\n"]

    shellCommandProcess.standardOutput = outputPipe
    shellCommandProcess.standardError = errorPipe
    shellCommandProcess.executableURL = URL(filePath: "/bin/bash")
    shellCommandProcess.arguments = ["-c", command]

    let outHandle = outputPipe.fileHandleForReading
    let errHandle = errorPipe.fileHandleForReading

    outHandle.waitForDataInBackgroundAndNotify()
    errHandle.waitForDataInBackgroundAndNotify()

    var outputData = Data()
    var errorData = Data()

    let stdoutFileHandle = FileHandle.standardOutput
    let stderrFileHandle = FileHandle.standardError
    
    var outputObserver: NSObjectProtocol?
    var errorObserver: NSObjectProtocol?

    NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) { _ in
        let availableData = outHandle.availableData
        outputData.append(availableData)
        stdoutFileHandle.write(availableData)
        outHandle.waitForDataInBackgroundAndNotify()
    }

    NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: errHandle, queue: nil) { _ in
        let availableData = errHandle.availableData
        errorData.append(availableData)
        stderrFileHandle.write(availableData)
        errHandle.waitForDataInBackgroundAndNotify()
    }

    try shellCommandProcess.run()
    shellCommandProcess.waitUntilExit()

    if let outputObserver = outputObserver {
        NotificationCenter.default.removeObserver(outputObserver)
    }

    if let errorObserver = errorObserver {
        NotificationCenter.default.removeObserver(errorObserver)
    }
    
    if !errorData.isEmpty {
        guard safeErrorMessages.contains(String(data: errorData, encoding: .utf8)!) else {
            throw ShellCommandError.RunCommandFailed(String(data: errorData, encoding: .utf8) ?? "")
        }
    }

    return outputData
}

/**
 * - parameter command: A String containing the command you want to run; Seperating the command isn't necessary.
 */
func runShellCommandDisplay(_ command: String) throws -> String? {
    let outdata = try runShellCommandWithDataOutputDisplay(command)
    let out = (outdata != nil) ? String(data: outdata!, encoding: .utf8) : nil
    return out
}

/**
 * - parameter command: A String containing the command you want to run; Seperating the command isn't necessary.
 */
func runShellCommandWithDataOutput(_ command: String) throws -> Data? {
    let shellCommandProcess = Process()
    let safeErrorMessages = ["Password:\n",
                             "Password:",
                             "Password:The disk contains an unclean file system (0, 0).\nThe file system wasn\'t safely closed on Windows. Fixing.\n"]
    
    shellCommandProcess.executableURL = URL(filePath: "/bin/bash")
    shellCommandProcess.arguments = ["-c", command]
    
    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    
    shellCommandProcess.standardError = stderrPipe
    shellCommandProcess.standardOutput = stdoutPipe
    
    do {
        try shellCommandProcess.run()
    } catch {
        throw error
    }
    
    shellCommandProcess.waitUntilExit()
    
    if let errdata = try? stderrPipe.fileHandleForReading.readToEnd() {
        let err = String(data: errdata, encoding: .utf8)!
        guard safeErrorMessages.contains(err) else {
            throw ShellCommandError.RunCommandFailed(err)
        }
    }
    
    let outdata = try? stdoutPipe.fileHandleForReading.readToEnd()
    
    return outdata
}

/**
 * - parameter command: A String containing the command you want to run; Seperating the command isn't necessary.
 */
func runShellCommand(_ command: String) throws -> String? {
    let outdata = try runShellCommandWithDataOutput(command)
    let out = (outdata != nil) ? String(data: outdata!, encoding: .utf8) : nil
    return out
}
