//
//  News.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 21/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation

import Gloss
import struct Gloss.JSON

import struct SwiftyJSON.JSON

private var dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "zh_Hans_CN")
  formatter.timeZone = NSTimeZone.local
  formatter.dateFormat = "yy-MM-dd HH:mm:ss"
  return formatter
}()

struct NewsItem: Decodable {
  let title: String
  let description: String
  let source: String
  let imageName: String
  let date: Date
  let readCount: UInt
  let url: URL


  // Gloss
  init?(json: Gloss.JSON) {
    guard
      let title: String = "title" <~~ json,
      let description: String = "description" <~~ json,
      let source: String = "source" <~~ json,
      let imageName: String = "image" <~~ json,
      let dateString: String = "date" <~~ json,
      let readCount: UInt = "read count" <~~ json,
      let urlString: String = "url" <~~ json
      else {
        return nil
    }

    self.title = title
    self.description = description
    self.source = source
    self.imageName = imageName
    guard let date = dateFormatter.date(from: dateString) else {
      Jack.error("fail to init a Date instance from\n\(dateString)")
      return nil
    }
    self.date = date
    self.readCount = readCount
    guard let url = URL(string: urlString) else {
      Jack.error("fail to init a URL instance from\n\(urlString)")
      return nil
    }
    self.url = url
  }

  init?(title: String, description: String, source: String, imageName: String, dateString: String, readCount: UInt, urlString: String) {
    self.title = title
    self.description = description
    self.source = source
    self.imageName = "未设定.jpg"
    guard let date = dateFormatter.date(from: dateString) else {
      Jack.error("fail to init a Date instance from\n\(dateString)")
      return nil
    }
    self.date = date
    self.readCount = 0
    guard let url = URL(string: urlString) else {
      Jack.error("fail to init a URL instance from\n\(urlString)")
      return nil
    }
    self.url = url
  }

  var timePassedDescription: String {
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: date, to: Date())

    let text: String
    if components.year! > 0 {
      text = "\(components.year!) 年前"
    } else if components.month! > 0 {
      text = "\(components.month!) 月前"
    } else if components.day! > 0 {
      text = "\(components.day!) 天前"
    } else if components.hour! > 0 {
      text = "\(components.hour!) 小时前"
    } else if components.minute! > 0 {
      text = "\(components.minute!) 分钟前"
    } else {
      text = "\(components.second!) 秒前"
    }

    return text
  }

  var dateString: String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_Hans_CN")
    formatter.timeZone = NSTimeZone.local
    formatter.dateFormat = "yy-MM-dd HH:mm:ss"

    return formatter.string(from: date)
  }
}

/**
 Read from News.json in main bunble, parse and return a array of NewsItem objects.
 The performance is, by a rough profiling, clearly slower than Gloss. So using gloss
 vertion of this method is preferred.

 - returns: [NewsItems]
 */
func loadNewsUsingSwiftyJSON() -> [NewsItem] {
  guard let url = theMainBundle.url(forResource: "News", withExtension: "json") else {
    fatalError("can not found url for News.json")
  }

  let newsJSON: SwiftyJSON.JSON
  do {
    let newsData = try Data(contentsOf: url)
    newsJSON = SwiftyJSON.JSON(data: newsData)
  } catch {
    fatalError(error.localizedDescription)
  }

  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "zh_Hans_CN")
  formatter.timeZone = NSTimeZone.local
  formatter.dateFormat = "yy-MM-dd HH:mm:ss"

  let newsList = newsJSON.reduce([NewsItem]()) {
    (list, element) -> [NewsItem] in

    let itemJSON = element.1
    let item = NewsItem(
      title: itemJSON["title"].string!,
      description: itemJSON["description"].string!,
      source: itemJSON["source"].string!,
      imageName: itemJSON["image"].string!,
      dateString: itemJSON["date"].string!,
      readCount: itemJSON["read count"].uInt!,
      urlString: itemJSON["url"].string!)!

    return list + [item]
  }

  return newsList
}


/**
 Read from News.json in main bunble, parse and return a array of NewsItem objects.
 The performance is, by a rough profiling, nearly 2 times faster than SwiftyJSON.

 - returns: [NewsItems]
 */
func loadNewsUsingGloss() -> [NewsItem] {
  guard let url = theMainBundle.url(forResource: "News", withExtension: "json") else {
    fatalError("can not found url for News.json")
  }

  let any: Any
  do {
    let newsData = try Data(contentsOf: url)
    any = try JSONSerialization.jsonObject(with: newsData, options: [])
  } catch {
    fatalError(error.localizedDescription)
  }

  return [NewsItem].from(jsonArray: any as! [Gloss.JSON])!
}
