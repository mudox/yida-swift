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

struct ClassRoster {

  var students: [Student]
  var studentsGroupedByClassID: [String: [Student]] = [:]

  enum SortingCriteria {
    case name, age, id, none
  }

  init(students: [Student]) {
    self.students = students

    for s in students {
      if studentsGroupedByClassID[s.classID] == nil {
        studentsGroupedByClassID[s.classID] = []
      }
      studentsGroupedByClassID[s.classID]?.append(s)
    }
  }

  // MARK: Sorting

  mutating func sortByName() {
    let sorter = { (left: Student, right: Student) -> Bool in
      let compareResult = left.fullName.compare(right.fullName, options: [], range: nil, locale: LocaleName.chineseChina.locale)
      return compareResult == .orderedAscending
    }

    students.sort(by: sorter)

    for key in studentsGroupedByClassID.keys {
      studentsGroupedByClassID[key]!.sort(by: sorter)
    }
  }

  mutating func sortByAge() {
    let sorter = { (left: Student, right: Student) -> Bool in
      return left.age < right.age
    }

    students.sort(by: sorter)

    for key in studentsGroupedByClassID.keys {
      studentsGroupedByClassID[key]!.sort(by: sorter)
    }
  }

  mutating func sortByID() {
    let sorter = { (left: Student, right: Student) -> Bool in
      return left.id < right.id
    }

    students.sort(by: sorter)

    for key in studentsGroupedByClassID.keys {
      studentsGroupedByClassID[key]!.sort(by: sorter)
    }
  }

  // MARK: Views

  var allClassIDs: [String] {
    mutating get {
      return studentsGroupedByClassID.keys.sorted()
    }
  }

  // MARK: Add/Delete/Move student

  mutating func removeStudent(_ student: Student) {
    let indexOrNil = students.index {
      (s: Student) -> Bool in
      s.id == student.id
    }

    if let index = indexOrNil {
      students.remove(at: index)
    } else {
      jack.warn("can not found the student to remove")
    }
  }

  mutating func addStudent(_ student: Student) {
    students.insert(student, at: 0)
    studentsGroupedByClassID[student.classID]!.insert(student, at: 0)
  }

  mutating func moveStudent(at from: Int, to: Int) {
    let sourceStudent = students[from]
    students.remove(at: from)
    students.insert(sourceStudent, at: to)
  }

  mutating func moveStudentInGroupedView(ofClass classID: String, at from: Int, to: Int) {
    let sourceStudent = studentsGroupedByClassID[classID]![from]
    studentsGroupedByClassID[classID]!.remove(at: from)
    studentsGroupedByClassID[classID]!.insert(sourceStudent, at: to)
  }
}

// MARK: - Generate fake data for demonstration
extension ClassRoster {
  /// Used to generate fake student ID sequentially
  static var fakeInstanceCount: UInt = 0

  /// Fake data source for demonstration
  static var fakeRoster: ClassRoster = {

    let students: [Student] = (0..<400).map { _ in
      return ClassRoster.aFakeStudent()
    }

    return ClassRoster(students: students)
  }()

  static func aFakeStudent() -> Student {
    let age = 16 + UInt(arc4random_uniform(5))

    // from A - Z
    let ordinal = UnicodeScalar(0x41 + arc4random_uniform(26))!
    let classID = String(Character(ordinal))

    let surname = DataSource.random.aSurname
    let name: String
    let gender: Student.Gender
    if arc4random_uniform(2) == 1 {
      gender = .male
      name = DataSource.random.aMaleName
    } else {
      gender = .female
      name = DataSource.random.aFemaleName
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

  mutating func addAFakeStudent(withClassID classIDOrNil: String? = nil) {
    var s = ClassRoster.aFakeStudent()
    if let classID = classIDOrNil {
      guard allClassIDs.contains(classID) else {
        fatalError()
      }
      s.classID = classID
    }

    addStudent(s)
  }
}
