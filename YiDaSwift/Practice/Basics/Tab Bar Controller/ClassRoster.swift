//
//  ClassRoster.swift
//  Main
//
//  Created by Mudox on 15/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation

fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

struct ClassRoster {

  init(students: [Student]) {
    self.students = students
    self.studentsTimeStamp = Date()
  }

  // Originally sorted by studnet ID
  var students: [Student]
  var studentsTimeStamp: Date

  private var groupedByClassView: (lastResult: [String: [Student]], timeStamp: Date) = ([:], .distantPast)
  var groupedByClass: [String: [Student]] {
    mutating get {

      if groupedByClassView.timeStamp.compare(studentsTimeStamp) == .orderedDescending {
        return groupedByClassView.lastResult
      }

      jack.debug("generate new result")

      var result: [String: [Student]] = [:]
      for s in students {
        result[s.classID] = result[s.classID] ?? [Student]()
        result[s.classID]?.append(s)
      }

      groupedByClassView.lastResult = result
      groupedByClassView.timeStamp = Date()

      return result
    }
  }

  private var sortedByNameView: (lastResult: [Student], timeStamp: Date) = ([], .distantPast)
  var sortedByName: [Student] {
    mutating get {
      if sortedByNameView.timeStamp.compare(studentsTimeStamp) == .orderedDescending {
        return sortedByNameView.lastResult
      }

      jack.debug("generate new result")

      let result = students.sorted {
        left, right in
        let result = left.fullName.localizedStandardCompare(right.fullName)
        return (result == .orderedAscending)
      }

      sortedByNameView.lastResult = result
      sortedByNameView.timeStamp = Date()

      return result
    }
  }

  private var sortedByAgeView: (lastResult: [Student], timeStamp: Date) = ([], .distantPast)
  var srotedByAge: [Student] {
    mutating get {
      if sortedByAgeView.timeStamp.compare(studentsTimeStamp) == .orderedDescending {
        return sortedByAgeView.lastResult
      }

      jack.debug("generate new result")

      let result = students.sorted {
        left, right in
        return left.age < right.age
      }

      sortedByAgeView.lastResult = result
      sortedByAgeView.timeStamp = Date()

      return result
    }
  }

  var allClassIDs: [String] {
    mutating get {
      return Array<String>(groupedByClass.keys).sorted()
    }
  }

}

// Generate fake data for demonstration
extension ClassRoster {
  /// Used generate fake student ID sequentially
  static var fakeInstanceCount = 0

  /// Fake data source for demonstration
  static var fakeRoster: ClassRoster = {

    let students: [Student] = (0..<400).map { _ in
      let surname = DataSource.random.aSurname
      let age = 16 + UInt(arc4random_uniform(5))

      // from A - Z
      let ordinal = UnicodeScalar(0x41 + arc4random_uniform(26))!
      let classID = String(Character(ordinal))

      let name: String
      let gender: Student.Gender
      if arc4random_uniform(2) == 1 {
        gender = .male
        name = DataSource.random.aMaleName
      } else {
        gender = .female
        name = DataSource.random.aSurname
      }

      fakeInstanceCount += 1
      let id = String(format: "YD-iOS-%05d", fakeInstanceCount)

      return Student(
        surname: surname,
        name: name,
        age: age,
        gender: gender,
        classID: classID,
        id: id
      )
    }

    return ClassRoster(students: students)
  }()
}
