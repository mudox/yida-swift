// ClassRoster.swift
//  Main
//
//  Created by Mudox on 15/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation
import SwiftDate

fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

struct ClassRoster {

  fileprivate var ungrouped: (list: [Student], date: Date) = ([], .distantPast)
  fileprivate var grouped: (dict: [String: [Student]], date: Date) = ([:], .distantPast)

  fileprivate var searchResult: (ungrouped: [Student], grouped: [String: [Student]], date: Date) = ([], [:], .distantPast)

  // nil for not searching
  var searchString: String = "" {
    didSet {
      if oldValue != searchString {
        if isSearchModeEnabled {
          updateSearchResult()
        }
      }
    }
  }

  var isSearchModeEnabled = false {
    didSet {
      if oldValue != isSearchModeEnabled {
        updateSearchResult()
      }
    }
  }

//  enum SortingCriteria {
//    case name, age, id, none
//  }

  init(students: [Student]) {
    ungrouped.list = students
    ungrouped.date = Date()

    grouped.dict = groupStudentsByClassID(ungrouped.list)
    grouped.date = Date()
  }

  /// Called in .init() & .updateSearchResult() method to (re)generate .grouped data structure
  mutating func groupStudentsByClassID(_ students: [Student]) -> [String: [Student]] {
    var dict: [String: [Student]] = [:]
    for s in students {
      if dict[s.classID] == nil {
        dict[s.classID] = []
      }
      dict[s.classID]?.append(s)
    }

    return dict
  }

  // MARK: Sorting

  mutating func sortByName() {
    let sorter = { (left: Student, right: Student) -> Bool in
      let compareResult = left.fullName.compare(right.fullName, options: [], range: nil, locale: LocaleName.chineseChina.locale)
      return compareResult == .orderedAscending
    }

    ungrouped.list.sort(by: sorter)
    grouped.dict = groupStudentsByClassID(ungrouped.list)

    searchResult.ungrouped.sort(by: sorter)
    searchResult.grouped = groupStudentsByClassID(searchResult.ungrouped)
  }

  mutating func sortByAge() {
    let sorter = { (left: Student, right: Student) -> Bool in
      return left.age < right.age
    }

    ungrouped.list.sort(by: sorter)
    grouped.dict = groupStudentsByClassID(ungrouped.list)

    searchResult.ungrouped.sort(by: sorter)
    searchResult.grouped = groupStudentsByClassID(searchResult.ungrouped)

  }

  mutating func sortByID() {
    let sorter = { (left: Student, right: Student) -> Bool in
      return left.id < right.id
    }

    ungrouped.list.sort(by: sorter)
    grouped.dict = groupStudentsByClassID(ungrouped.list)

    searchResult.ungrouped.sort(by: sorter)
    searchResult.grouped = groupStudentsByClassID(searchResult.ungrouped)

  }

  // MARK: Views

  var allClassIDs: [String] {
    mutating get {
      return groupedView.keys.sorted()
    }
  }

  mutating func updateSearchResult() {
    guard !searchString.isEmpty else {
      searchResult = (ungrouped.list, grouped.dict, Date())
      return
    }

    jack.debug("apply search with work: \(searchString)")

    self.searchResult.ungrouped = ungrouped.list.filter { (s: Student) -> Bool in
      let pinyin = s.fullName.toPinyin()
      let pinyinAcronym = s.fullName.toPinyinAcronym()
      let allInOneText = "\(pinyin)\(pinyinAcronym)\(s.fullName)\(s.age)\(s.gender)\(s.classID)\(s.idString)"
      return allInOneText.contains(searchString)
    }

    searchResult.grouped = groupStudentsByClassID(searchResult.ungrouped)

    self.searchResult.date = Date()
  }

  /// It take search string into consideration, if searh string is nil return the back store directly.
  var ungroupedView: [Student] {
    mutating get {
      if isSearchModeEnabled {
        return searchResult.ungrouped
      } else {
        return ungrouped.list
      }
    }
  }

  /// It take search string into consideration, if searh string is nil return the back store directly.
  var groupedView: [String: [Student]] {
    mutating get {
      if isSearchModeEnabled {
        return searchResult.grouped
      } else {
        return grouped.dict
      }
    }
  }

  // MARK: Add/Delete/Move student

  mutating func removeStudent(_ student: Student) {
    var index = ungrouped.list.index(where: {
      (s: Student) -> Bool in
      s.id == student.id
    })!
    ungrouped.list.remove(at: index)
    ungrouped.date = Date()

    index = grouped.dict[student.classID]!.index(where: {
      (s: Student) -> Bool in
      s.id == student.id
    })!
    grouped.dict[student.classID]!.remove(at: index)
    grouped.date = Date()

    updateSearchResult()
  }

  mutating func addStudent(_ student: Student) {
    ungrouped.list.insert(student, at: 0)
    ungrouped.date = Date()

    grouped.dict[student.classID]!.insert(student, at: 0)
    grouped.date = Date()

    updateSearchResult()
  }

  mutating func moveStudent(at from: Int, to: Int) {
    let sourceStudent = ungrouped.list[from]
    ungrouped.list.remove(at: from)
    ungrouped.list.insert(sourceStudent, at: to)
    ungrouped.date = Date()

    updateSearchResult()
  }

  mutating func moveStudentInGroupedView(ofClass classID: String, at from: Int, to: Int) {
    let sourceStudent = grouped.dict[classID]![from]
    grouped.dict[classID]!.remove(at: from)
    grouped.dict[classID]!.insert(sourceStudent, at: to)
    grouped.date = Date()

    updateSearchResult()
  }
}

// MARK: - Generate fake data for demonstration
extension ClassRoster {
  /// Used to generate fake student ID sequentially
  static var fakeInstanceCount: UInt = 0

  /// Fake data source for demonstration
  static var fakeRoster: ClassRoster = {

    let fakeStudents: [Student] = (0..<400).map { _ in
      return ClassRoster.aFakeStudent()
    }

    return ClassRoster(students: fakeStudents)
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
