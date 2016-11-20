//
//  ClassRosterTableHeaderView.swift
//  Main
//
//  Created by Mudox on 16/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit
import SnapKit

class ClassRosterTableHeaderView: UITableViewHeaderFooterView {

  /// Use it as the header view reuse identifier for table header view registration
  static let identifier = "Class Roster Table Header View"

  /** Return it for both

   - tableView(_:heightForHeaderInSection:)
   - tableView(_:estimatedHeightForHeaderInSection:)
   
   table view delegate methods
   */
  static let viewHeight: CGFloat = 48

  var classIDLabel = UILabel()
  var classSummaryLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: ClassRosterTableHeaderView.identifier)
    initSelf()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var gradientLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.colors = [
      theWindow.tintColor.cgColor,
      theWindow.tintColor.cgColor,
      UIColor(white: 1, alpha: 0).cgColor
    ]
    layer.locations = [0, 0.3, 0.85] as [NSNumber]
    layer.startPoint = CGPoint(x: 0, y: 0.5)
    layer.endPoint = CGPoint(x: 1.2, y: 0.5)
    return layer
  }()

  func initSelf() {
    contentView.backgroundColor = .white

    // class ID label
    classIDLabel.textColor = .white
    classIDLabel.layer.insertSublayer(gradientLayer, at: 0)

    classIDLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
    classIDLabel.textAlignment = .center

    contentView.addSubview(classIDLabel)
    classIDLabel.snp.makeConstraints { make in
      make.height.equalTo(23)
      make.leading.equalTo(self)
      make.bottom.equalTo(self).offset(-4)
    }

    // class summary text label
    classSummaryLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)

    contentView.addSubview(classSummaryLabel)
    classSummaryLabel.snp.makeConstraints { (make) in
      make.lastBaseline.equalTo(classIDLabel)
      make.trailing.equalTo(self).offset(-20)
    }
  }

  override func tintColorDidChange() {
    classSummaryLabel.textColor = theWindow.tintColor
  }

  func set(withClassInfo studentList: [Student]) {
    let classID = studentList[0].classID
    classIDLabel.text = " iOS \(classID) 班"

    var maleCount = 0
    var femaleCount = 0
    for s in studentList {
      if s.gender == .male {
        maleCount += 1
      } else {
        femaleCount += 1
      }
    }

    let summaryText = "\(maleCount)男 \(femaleCount)女 总计\(studentList.count)名学员"
    classSummaryLabel.text = summaryText
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    gradientLayer.frame = classIDLabel.bounds
    gradientLayer.frame.size.width += 40
  }

}
