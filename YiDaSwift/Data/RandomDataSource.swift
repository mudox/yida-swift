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
    return try! String.init(contentsOf: url)
  }()

  private static var femaleNames: String = {
    let url = Bundle.main.url(forResource: "CNFemaleNames", withExtension: "")!
    return try! String.init(contentsOf: url)
  }()

  private static var surnames: String = {
    let url = Bundle.main.url(forResource: "CNSurnames", withExtension: "")!
    return try! String.init(contentsOf: url)
  }()

  /// a chinese full name regardless of gender
  static var aFullName: String {
    return aSurname + ((arc4random_uniform(2) == 1) ? aMaleName : aFemaleName)
  }

  static var aSurname: String {
    let count = surnames.characters.count
    let start = surnames.startIndex
    let lower = surnames.index(start, offsetBy: String.IndexDistance(arc4random_uniform(UInt32(count))))
    let upper = surnames.index(after: lower)
    return surnames.substring(with: lower..<upper)
  }

  /// a chinese name (without surname) regardless of gender
  static var aName: String {
    return arc4random_uniform(1) == 1 ? aMaleName : aFemaleName
  }

  static var aMaleName: String {
    let names = maleNames
    let count = names.characters.count
    let index = names.startIndex

    var theName = ""
    for _ in 0...arc4random_uniform(2)  {
      let lower = names.index(index, offsetBy: String.IndexDistance(arc4random_uniform(UInt32(count))))
      let upper = names.index(after: lower)
      let name = names.substring(with: lower..<upper)
      theName += name
    }

    return theName
  }

  static var aFemaleName: String {
    let names = femaleNames
    let count = names.characters.count
    let index = names.startIndex

    var theName = ""
    for _ in 0...arc4random_uniform(2) {
      let lower = names.index(index, offsetBy: String.IndexDistance(arc4random_uniform(UInt32(count))))
      let upper = names.index(after: lower)
      let name = names.substring(with: lower..<upper)
      theName += name
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
