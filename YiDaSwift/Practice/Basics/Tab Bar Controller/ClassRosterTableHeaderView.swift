//
//  ClassRosterTableHeaderView.swift
//  Main
//
//  Created by Mudox on 16/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class ClassRosterTableHeaderView: UITableViewHeaderFooterView {

  /// Use it as the header view reuse identifier for table header view registration
  static let identifier = "Class Roster Table Header View"

  /** Return it for both

   - tableView(_:heightForHeaderInSection:)
   - tableView(_:estimatedHeightForHeaderInSection:)
   
   table view delegate methods
   */
  static let viewHeight: CGFloat = 40

  var classIDLabel = UILabel()
  var classSummaryLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: ClassRosterTableHeaderView.identifier)
    initSelf()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func initSelf() {
    contentView.backgroundColor = .white

    // class ID label
    classIDLabel.textColor = .white
    let cornerRadius: CGFloat = 3
    classIDLabel.layer.cornerRadius = cornerRadius
    classIDLabel.layer.masksToBounds = true
    classIDLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
    classIDLabel.textAlignment = .center

    contentView.addSubview(classIDLabel)
    classIDLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      classIDLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      classIDLabel.widthAnchor.constraint(equalToConstant: 72),
      classIDLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -cornerRadius),
    ])

    // class summary text label
    classSummaryLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)

    contentView.addSubview(classSummaryLabel)
    classSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      classSummaryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      classSummaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
    ])
  }

  override func tintColorDidChange() {
    classIDLabel.backgroundColor = theWindow.tintColor
    classSummaryLabel.textColor = theWindow.tintColor
  }

  func set(withClassInfo studentList: [Student]) {
    let classID = studentList[0].classID
    classIDLabel.text = "iOS \(classID) 班"

    var maleCount = 0
    var femaleCount = 0
    for s in studentList {
      if s.gender == .male {
        maleCount += 1
      } else {
        femaleCount += 1
      }
    }

    let summaryText = "男:\(maleCount) 女:\(femaleCount) 总计\(studentList.count)名学员"
    classSummaryLabel.text = summaryText
  }

}
