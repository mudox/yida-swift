//
//  RandomDataSource.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 26/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

struct RandomDataSource {
  // MARK: names & age
  private static var maleNames: String = {
    let url = Bundle.main.url(forResource: "CNMaleNames", withExtension: "")!
    let text = try! String.init(contentsOf: url)
    return String(text.characters.dropLast())
  }()

  private static var femaleNames: String = {
    let url = Bundle.main.url(forResource: "CNFemaleNames", withExtension: "")!
    let text = try! String.init(contentsOf: url)
    return String(text.characters.dropLast())
  }()

  private static var surnames: String = {
    let url = Bundle.main.url(forResource: "CNSurnames", withExtension: "")!
    let text = try! String.init(contentsOf: url)
    return String(text.characters.dropLast())
  }()

  /// a chinese full name regardless of gender
  static var aFullName: String {
    return aSurname + ((arc4random_uniform(2) == 1) ? aMaleName : aFemaleName)
  }

  static var aSurname: String {
    let count = surnames.characters.count
    let index = surnames.index(surnames.startIndex, offsetBy: String.IndexDistance(arc4random_uniform(UInt32(count))))
    return String(surnames[index])
  }

  /// a chinese name (without surname) regardless of gender
  static var aName: String {
    return arc4random_uniform(1) == 1 ? aMaleName : aFemaleName
  }

  static var aMaleName: String {
    let names = maleNames
    let count = names.characters.count

    var theName = ""
    for _ in 0...arc4random_uniform(2) {
      let index = names.index(names.startIndex, offsetBy: String.IndexDistance(arc4random_uniform(UInt32(count))))
      let name = names[index]
      theName.append(name)
    }

    return theName
  }

  static var aFemaleName: String {
    let names = femaleNames
    let count = names.characters.count

    var theName = ""
    for _ in 0...arc4random_uniform(2) {
      let index = names.index(names.startIndex, offsetBy: String.IndexDistance(arc4random_uniform(UInt32(count))))
      let name = names[index]
      theName.append(name)
    }

    return theName
  }

  static func aAge(from: UInt32, to: UInt32) -> UInt32 {
    guard to > from else {
      fatalError()
    }

    return from + arc4random_uniform(to - from)
  }

  // MARK: phone numbers
  static func aPhoneNumber() -> String {
    let first3Digits = 120 + arc4random_uniform(80)
    let last8Digits = arc4random_uniform(100000000)
    return "\(first3Digits)\(last8Digits)"
  }
}
