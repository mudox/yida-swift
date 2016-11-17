//
//  CustomTabBar.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 20/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class CustomTabBar: UIView {

  let bar = UIImageView()
  let tabs = [UIButton](repeating: UIButton(type: .custom), count: 4)
  var barHeight: CGFloat = 49.0

  private func initSubviews() {
    bar.frame = CGRect(
      x: 0.0,
      y: theWindow.bounds.height - barHeight,
      width: theWindow.bounds.width,
      height: barHeight
    )
  }
}
