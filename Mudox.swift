//
//  Mudox.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 9/9/16.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation
import CocoaLumberjack

// Internal global commonly used objects
let theApp = UIApplication.shared
let theAppDelegate = UIApplication.shared.delegate as! AppDelegate
let theWindow = UIApplication.shared.keyWindow!
let theFileManager = FileManager.default
let theNotificationCenter = NotificationCenter.default
let theUserDefaults = UserDefaults.standard
let theMainBundle = Bundle.main

/** 
 *  My wrapper of CocoaLumberjack to use Swift syntax sugar
 */
struct Jack {

  static var levelOfFile = [String: DDLogLevel]()

  /**
   In the start of each file that you want to set a per file debug severity level for, add following line:
   `fileprivate let jack = Jack.with(levelOfThisFile: .warning)`
   
   - parameter level:    <#level description#>
   - parameter fileName: <#fileName description#>
   
   - returns: <#return value description#>
   */
  static func with(levelOfThisFile level: DDLogLevel, _ fileName: String = #file) -> Jack.Type {
    setLevelOfThisFile(level, fileName)
    return Jack.self
  }

  static func setLevelOfThisFile(_ level: DDLogLevel, _ fileName: String = #file) {
    levelOfFile[fileName] = level
  }

  static func levelOfFile(_ fileName: String) -> DDLogLevel {
    if let level = levelOfFile[fileName] {
      return level
    } else {
      return defaultDebugLevel
    }
  }

  static func wakeUp() {
    let formatter = JackFormatter()

    // Xcode debug area
    let ttyLogger = DDTTYLogger.sharedInstance()!
    ttyLogger.logFormatter = formatter
    DDLog.add(ttyLogger)

    // Log to file
    let logFileManager = DDLogFileManagerDefault(logsDirectory: "/tmp/mudox/log/Xcode/CocoaLumberjack")
    let fileLogger = DDFileLogger(logFileManager: logFileManager)!
    fileLogger.logFormatter = formatter
    DDLog.add(fileLogger)

    Jack.greet()
  }

  enum Prefix {
    case appName, fileFunctionName
    case text(String)
  }

  static let appName = ProcessInfo.processInfo.processName

  static let indentRegex = try! NSRegularExpression(pattern: "\\n([^\\n ]{2})", options: [])

  /** 
   compose log line(s) to feed into DDLogXXXX functions

   - parameter message:  message content
   - parameter prefix:   one of .appName | .fileFunctionName | .text(<whatever you want>)
   - parameter file:     file name of call site
   - parameter function: function / method name of the call site

   - returns: the line(s) string with which to feed the DDLogXXXX functions
   */
  private static func log(_ message: String,
    _ prefix: Prefix,
    _ file: String,
    _ function: String) -> String {

      // prefix continued none empty lines with `>> `
      var log = indentRegex.stringByReplacingMatches(
        in: message, options: [], range: NSMakeRange(0, (message as NSString).length), withTemplate: "\n>> $1")

      switch prefix {
      case .appName:
        log = "\(appName): " + log
      case .fileFunctionName:
        let fileName = URL(fileURLWithPath: file).lastPathComponent as NSString
        let name = fileName.substring(to: fileName.length - 5)
        log = "\(name) \(function)] " + log
      case .text(let content):
        log = "\(content): " + log
      }

      return log
  }

  static func error(
    _ message: @autoclosure() -> String,
    withPrefix prefix: Prefix = .fileFunctionName,
    _ file: String = #file,
    _ function: String = #function) {

      if DDLogFlag.error.rawValue & levelOfFile(file).rawValue != 0 {
        DDLogError(log(message(), prefix, file, function), level: levelOfFile(file))
      }
  }

  static func warn(
    _ message: @autoclosure() -> String,
    withPrefix prefix: Prefix = .fileFunctionName,
    _ file: String = #file,
    _ function: String = #function) {

      if DDLogFlag.warning.rawValue & levelOfFile(file).rawValue != 0 {
        DDLogWarn(log(message(), prefix, file, function), level: levelOfFile(file))
      }
  }

  static func info(
    _ message: @autoclosure() -> String,
    withPrefix prefix: Prefix = .fileFunctionName,
    _ file: String = #file,
    _ function: String = #function) {

      if DDLogFlag.info.rawValue & levelOfFile(file).rawValue != 0 {
        DDLogInfo(log(message(), prefix, file, function), level: levelOfFile(file))
      }
  }

  static func debug(
    _ message: @autoclosure() -> String,
    withPrefix prefix: Prefix = .fileFunctionName,
    _ file: String = #file,
    _ function: String = #function) {

      if DDLogFlag.debug.rawValue & levelOfFile(file).rawValue != 0 {
        DDLogDebug(log(message(), prefix, file, function), level: levelOfFile(file))
      }
  }

  static func verbose(
    _ message: @autoclosure() -> String,
    withPrefix prefix: Prefix = .fileFunctionName,
    _ file: String = #file,
    _ function: String = #function) {

      if DDLogFlag.verbose.rawValue & levelOfFile(file).rawValue != 0 {
        DDLogVerbose(log(message(), prefix, file, function), level: levelOfFile(file))
      }
  }

  static func greet() {
    var greeting: String = "launched"

    let time = Date()
    greeting += "\nat: \(time)"

    let device = UIDevice.current
    let platform = "\(device.model) (\(device.systemName) \(device.systemVersion))"
    greeting += "\non: \(platform)"

    warn(greeting + "\n\n", withPrefix: .appName)
  }
}

private class JackFormatter: NSObject, DDLogFormatter {

  func format(message logMessage: DDLogMessage!) -> String {
    let prefix: String
    switch logMessage.flag {
    case DDLogFlag.error:
      prefix = "E"
    case DDLogFlag.warning:
      prefix = "W"
    case DDLogFlag.info:
      prefix = "I"
    case DDLogFlag.debug:
      prefix = "D"
    case DDLogFlag.verbose:
      prefix = "V"
    default:
      assertionFailure("Invalid DDLogFlag value")
      prefix = "):"
    }

    return "\(prefix)| \(logMessage.message!)"
  }
}

