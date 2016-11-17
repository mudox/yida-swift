//
//  PracticeMenu.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 23/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation

import struct Gloss.JSON
import Gloss

struct Menu: Decodable {
  let basicPart: [MenuSection]
  let advancedPart: [MenuSection]
  let frameworkPart: [MenuSection]

  init?(json: Gloss.JSON) {
    guard
      let basicPart = [MenuSection].from(jsonArray: json["basic"] as! [Gloss.JSON]),
      let advancedPart = [MenuSection].from(jsonArray: json["advanced"] as! [Gloss.JSON]),
      let frameworkPart = [MenuSection].from(jsonArray: json["3rd party frameworks"] as! [Gloss.JSON])
      else {
      return nil
    }

    self.basicPart = basicPart
    self.advancedPart = advancedPart
    self.frameworkPart = frameworkPart
  }

  static var shared: Menu = {
    let url = theMainBundle.url(forResource: "Menu", withExtension: "json")!
    let any: Any
    do {
      let data = try Data(contentsOf: url)
      any = try JSONSerialization.jsonObject(with: data, options: [])
    } catch {
      fatalError(error.localizedDescription)
    }

    return Menu(json: any as! Gloss.JSON)!
  }()
}

struct MenuSection: Decodable {
  let headerText: String
  let items: [MenuItem]

  init?(json: JSON) {
    guard
      let headerText: String = "headerText" <~~ json,
      let items = [MenuItem].from(jsonArray: json["items"] as! [Gloss.JSON])
      else {
      return nil
    }

    self.headerText = headerText
    self.items = items
  }
}

struct MenuItem: Decodable {
  let title: String
  let subtitle: String
  let storyboardName: String
  let viewControllerReferenceID: String
  var presenting: String?

  var isAvailable: Bool {
    return storyboardName != "" && viewControllerReferenceID != ""
  }

  init?(json: JSON) {
    guard
      let title: String = "title" <~~ json,
      let subtitle: String = "subtitle" <~~ json,
      let storyboardName: String = "storyboardName" <~~ json,
      let viewControllerReferenceID: String = "viewControllerReferenceID" <~~ json
      else {
      return nil
    }

    self.title = title
    self.subtitle = subtitle
    self.storyboardName = storyboardName
    self.viewControllerReferenceID = viewControllerReferenceID
    self.presenting = "presenting" <~~ json
  }
}
