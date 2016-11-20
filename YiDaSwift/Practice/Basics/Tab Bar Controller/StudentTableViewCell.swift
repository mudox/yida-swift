//
//  StudentTableViewCell.swift
//  Main
//
//  Created by Mudox on 15/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class StudentTableViewCell: UITableViewCell {

  static let identifier = "Student Table View Cell"

  // MARK: Outlets
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet weak var genderLabel: UILabel!
  @IBOutlet var classIDLabel: UILabel!
  @IBOutlet weak var studentIDLabel: UILabel!

  func set(withInfo student: Student) {
    nameLabel.text = student.fullName
    ageLabel.text = "\(student.age) 岁"
    genderLabel.text = (student.gender == .male) ? "男" : "女"
    classIDLabel.text = "\(student.classID) 班"
    studentIDLabel.text = student.idString

    let fontSize: CGFloat = 13
    let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFontWeightThin)
    genderLabel.font = monospacedFont
    ageLabel.font = monospacedFont
    studentIDLabel.font = monospacedFont
    classIDLabel.font = monospacedFont
  }
}
