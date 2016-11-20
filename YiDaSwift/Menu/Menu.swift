//
//  PracticeMenu.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 23/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation

import Gloss

struct MenuItemState: OptionSet, Hashable {
  let rawValue: Int

  var hashValue: Int {
    return rawValue
  }

  static let goodToGo = MenuItemState(rawValue: 1 << 0)
  static let planning = MenuItemState(rawValue: 1 << 1)
  static let workingInProcess = MenuItemState(rawValue: 1 << 2)
  static let pinned = MenuItemState(rawValue: 1 << 3)

  static let canOpen: MenuItemState = [.goodToGo, .workingInProcess, .pinned]
  static let all: MenuItemState = [.goodToGo, .workingInProcess, .pinned, .planning]
}

struct Menu: Decodable {

  let basicPart: MenuPart
  let advancedPart: MenuPart
  let frameworkPart: MenuPart

  init?(json: JSON) {
    basicPart = MenuPart(jsonArray: json["basic"] as! [JSON])
    advancedPart = MenuPart(jsonArray: json["advanced"] as! [JSON])
    frameworkPart = MenuPart(jsonArray: json["framework"] as! [JSON])
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

    return Menu(json: any as! JSON)!
  }()
}

struct MenuPart {

  var sections: [MenuSection]

  var filteredSections: [MenuSection] = []

  var filterItemStates: MenuItemState = .all {
    didSet {
      if oldValue != filterItemStates {
        updateFiteredView()
      }
    }
  }

  lazy var itemCounts: [MenuItemState: Int] = {
    var counts: [MenuItemState: Int] = [
        .goodToGo: 0, .pinned: 0, .workingInProcess: 0, .planning: 0, .all: 0
    ]

    self.sections.forEach {
      $0.items.forEach {
        counts[$0.state]! += 1
        counts[.all]! += 1
      }
    }

    return counts
  }()

  mutating func updateFiteredView() {
    if filterItemStates == .all {
      filteredSections = sections
      return
    }

    let filtered = sections.flatMap { section -> MenuSection? in
      let filteredItems = section.items.filter { item -> Bool in
        return self.filterItemStates.contains(item.state)
      }

      if filteredItems.isEmpty {
        return nil
      } else {
        return MenuSection(headerText: section.headerText, items: filteredItems)
      }
    }

    filteredSections = filtered
  }

  init(jsonArray: [JSON]) {
    sections = [MenuSection].from(jsonArray: jsonArray)!
    updateFiteredView()
  }
}

struct MenuSection: Decodable {
  let headerText: String
  let items: [MenuItem]

  init(headerText: String, items: [MenuItem]) {
    self.headerText = headerText
    self.items = items
  }

  init?(json: JSON) {
    guard
    let headerText: String = "headerText" <~~ json,
      let items = [MenuItem].from(jsonArray: json["items"] as! [JSON])
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
  var stateText: String?

  var state: MenuItemState {
    if storyboardName == "" || viewControllerReferenceID == "" {
      return .planning
    } else {
      if stateText == nil {
        return .workingInProcess
      } else {
        switch stateText! {
        case "Good To Go":
          return .goodToGo
        case "Working In Process":
          return .workingInProcess
        case "Planning":
          return .planning
        case "Pinned":
          return .pinned
        default:
          fatalError()
        }
      }
    }
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

    // those properties can be absent
    self.presenting = "presenting" <~~ json
    self.stateText = "state" <~~ json
  }
}
