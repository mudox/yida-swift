//
//  ClassRoster.swift
//  Main
//
//  Created by Mudox on 15/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation
import SwiftDate

fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

fileprivate func sortStudentsByName(_ students: [Student]) -> [Student] {
  return students.sorted {
    let compareResult = $0.fullName.compare($1.fullName, options: [], range: nil, locale: LocaleName.chineseChina.locale)
    return compareResult == .orderedAscending
  }
}

fileprivate func sortStudentsByAge(_ students: [Student]) -> [Student] {
  return students.sorted {
    return $0.age < $1.age
  }
}

fileprivate func sortStudentsByID(_ students: [Student]) -> [Student] {
  return students.sorted {
    return $0.id < $1.id
  }
}

struct ClassRoster {

  enum SortingCriteria {
    case name, age, id
  }

  init(students: [Student]) {
    self.students = (students, Date())
  }

  var sortingCriteriaTimeStamp: Date = .distantPast
  var sortingCriteria: SortingCriteria = .id {
    didSet {
      if oldValue != sortingCriteria {
        sortingCriteriaTimeStamp = Date()
      }
    }
  }

  fileprivate var students: (data: [Student], timestamp: Date)
  fileprivate var groupedView: (lastResult: [String: [Student]], timestamp: Date) = ([:], .distantPast)
  fileprivate var ungroupedView: (lastResult: [Student], timestamp: Date) = ([], .distantPast)
}

// MARK: - Data views
extension ClassRoster {

  /** 
   Students list grouped by class ID and ordered by .sortingCriteria within each group.
   Result is cached, only regenerate if needed.
   */
  var grouped: [String: [Student]] {
    mutating get {

      if groupedView.timestamp >= students.timestamp
      && groupedView.timestamp >= sortingCriteriaTimeStamp {
        return groupedView.lastResult
      }

      jack.debug("generate new result")

      var result: [String: [Student]] = [:]
      for s in students.data {
        result[s.classID] = result[s.classID] ?? [Student]()
        result[s.classID]?.append(s)
      }

      switch sortingCriteria {
      case .name:
        for (key, students) in result {
          result[key] = sortStudentsByName(students)
        }
      case .age:
        for (key, students) in result {
          result[key] = sortStudentsByAge(students)
        }
      case .id:
        for (key, students) in result {
          result[key] = sortStudentsByID(students)
        }
      }

      groupedView.lastResult = result
      groupedView.timestamp = Date()

      return result
    }
  }

  var allClassIDs: [String] {
    mutating get {
      return grouped.keys.sorted()
    }
  }

  /** 
   Students list ungrouped (in one list) ordered by .sortingCriteria.
   Result is cached, only regenerate if needed.
   */
  var ungrouped: [Student] {
    mutating get {
      if ungroupedView.timestamp >= students.timestamp
      && ungroupedView.timestamp >= sortingCriteriaTimeStamp {
        return ungroupedView.lastResult
      }

      jack.debug("generate new result")

      let result: [Student]
      switch sortingCriteria {
      case .name:
        result = sortStudentsByName(students.data)
      case .age:
        result = sortStudentsByAge(students.data)
      case .id:
        result = sortStudentsByID(students.data)
      }

      ungroupedView.lastResult = result
      ungroupedView.timestamp = Date()

      return result
    }
  }

}

// MARK: - Generate fake data for demonstration
extension ClassRoster {
  /// Used to generate fake student ID sequentially
  static var fakeInstanceCount: UInt = 0

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

      return Student(
        surname: surname,
        name: name,
        age: age,
        gender: gender,
        classID: classID,
        id: fakeInstanceCount
      )
    }

    return ClassRoster(students: students)
  }()
}
