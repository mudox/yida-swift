//
//  LyricsParser.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 26/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation
import AVFoundation

struct LyricsParse {
  
  static let lineRegex: NSRegularExpression = {
    let prefixingTimeStamp = "( \\[ \\d\\d : \\d\\d (\\.\\d\\d)? \\] \\s* )+"
    let lyricsText = "(.*)"
    return try! NSRegularExpression(
      pattern: prefixingTimeStamp + lyricsText,
      options: [.allowCommentsAndWhitespace]
    )
  }()
  
  static let timestampRegex = try! NSRegularExpression(
    pattern: "\\[ \\d\\d: \\d\\d (\\.\\d\\d)? \\]",
    options: [.allowCommentsAndWhitespace]
  )
  
  typealias ParseResult = [(timestamp: TimeInterval, text: String)]
  
  static func parse(_ lyricsText: String) -> ParseResult {
    
    var resultList = ParseResult()
    
    lyricsText.enumerateLines { (line, stop) in
      if let match = lineRegex.firstMatch(in: line, options: [], range: NSMakeRange(0, line.characters.count)) {
        // a valid timeline line
        let lyricsText = (line as NSString).substring(with: match.rangeAt(match.numberOfRanges - 1))
        let matches = timestampRegex.matches(in: line, options: [], range: NSMakeRange(0, line.characters.count))
        let timestamps = matches.map { (match: NSTextCheckingResult) -> TimeInterval in
          let stamp = (line as NSString).substring(with: match.range) as NSString
          let minuteText = stamp.substring(with: NSMakeRange(1, 2))
          let secondText = stamp.substring(with: NSMakeRange(4, 2))
          return TimeInterval(minuteText)! * 60 + TimeInterval(secondText)!
        }
        
        for timePoint in timestamps {
          resultList.append((timePoint, lyricsText))
        }
      }
    }
    
    resultList.sort { (lhs: (timestamp: TimeInterval, _: String), rhs: (timestamp: TimeInterval, _: String)) -> Bool in
      return lhs.timestamp < rhs.timestamp
    }
    
    return resultList
  }
}
