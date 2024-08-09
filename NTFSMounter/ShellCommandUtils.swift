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

    shellCommandProcess.standardOutput = outputPipe
    shellCommandProcess.standardError = outputPipe
    shellCommandProcess.executableURL = URL(filePath: "/bin/bash")
    shellCommandProcess.arguments = ["-c", command]

    let outHandle = outputPipe.fileHandleForReading
    outHandle.waitForDataInBackgroundAndNotify()

    let stdoutFileHandle = FileHandle.standardOutput
    
    let outputObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) { _ in
        stdoutFileHandle.write(outHandle.availableData)
        outHandle.waitForDataInBackgroundAndNotify()
    }
    
    do {
        try shellCommandProcess.run()
    } catch {
        throw error
    }

    shellCommandProcess.waitUntilExit()
    NotificationCenter.default.removeObserver(outputObserver)
    guard shellCommandProcess.terminationStatus != 0 else {
        throw ShellCommandError.RunCommandFailed(shellCommandProcess.terminationStatus)
    }
    let outputData = try? stdoutFileHandle.readToEnd()
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
    let stdoutPipe = Pipe()

    shellCommandProcess.executableURL = URL(filePath: "/bin/bash")
    shellCommandProcess.arguments = ["-c", command]
    shellCommandProcess.standardOutput = stdoutPipe
    shellCommandProcess.standardError = stdoutPipe
    
    do {
        try shellCommandProcess.run()
    } catch {
        throw error
    }
    
    shellCommandProcess.waitUntilExit()
    guard shellCommandProcess.terminationStatus != 0 else {
        throw ShellCommandError.RunCommandFailed(shellCommandProcess.terminationStatus)
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
