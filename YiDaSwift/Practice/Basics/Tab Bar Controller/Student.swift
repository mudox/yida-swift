//
//  YiDaStudent.swift
//  Main
//
//  Created by Mudox on 15/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation

struct Student {

  enum Gender {
    case male, female
  }

  var surname: String
  var name: String
  var fullName: String {
    return "\(surname)\(name)"
  }

  var age: UInt
  var gender: Gender
  var classID: String
  var id: String

}

extension Student: CustomStringConvertible {
  var description: String {
    return "\(fullName) \((gender == .male) ? "男" : "女") \(age)岁, \(classID)学员 学号 \(id)"
  }
}
