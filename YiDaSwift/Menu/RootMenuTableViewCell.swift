//
//  RootMenuTableViewCell.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 9/21/16.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class RootMenuTableViewCell: UITableViewCell {
  @IBOutlet weak var titleLabel: TintedLabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var stateLabel: UILabel!

  lazy var focusGradientLayer: CAGradientLayer = {
    self.backgroundView = UIView()

    let layer = CAGradientLayer()

    layer.colors = [
      theWindow.tintColor.cgColor,
      theWindow.tintColor.withAlphaComponent(0.7).cgColor,
      UIColor(white: 1, alpha: 0).cgColor
    ]
    layer.locations = [0, 0.65, 1] as [NSNumber]
    layer.startPoint = CGPoint(x: 0, y: 0.55)
    layer.endPoint = CGPoint(x: 1, y: 0.45)

    return layer
  }()

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code

    stateLabel.transform = CGAffineTransform(rotationAngle: -45.0 * CGFloat(M_PI) / 180.0)
    stateLabel.layer.cornerRadius = 3
    stateLabel.layer.masksToBounds = true
  }

  func setup(with item: MenuItem) {
    titleLabel.text = item.title
    subtitleLabel.text = item.subtitle
    accessibilityIdentifier = item.viewControllerReferenceID

    let stateAlpha: CGFloat
    switch item.state {

    case MenuItemState.planning:
      stateAlpha = 0.4

      selectionStyle = .none

      titleLabel.isAutoTintEnabled = false
      titleLabel.textColor = .darkGray
      titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)

      stateLabel.text = "N/A"
      stateLabel.textColor = .white
      stateLabel.backgroundColor = .lightGray
      stateLabel.layer.borderWidth = 0

      subtitleLabel.textColor = .lightGray

      focusGradientLayer.removeFromSuperlayer()

    case MenuItemState.workingInProcess:
      stateAlpha = 0.8

      selectionStyle = .default

      titleLabel.isAutoTintEnabled = true
      titleLabel.textColor = theWindow.tintColor
      titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)

      stateLabel.text = "WIP"
      stateLabel.textColor = .white
      stateLabel.backgroundColor = theWindow.tintColor
      stateLabel.layer.borderWidth = 0

      subtitleLabel.textColor = .lightGray

      focusGradientLayer.removeFromSuperlayer()

    case MenuItemState.pinned:
      stateAlpha = 1

      selectionStyle = .default

      titleLabel.isAutoTintEnabled = false
      titleLabel.textColor = .white
      titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)

      stateLabel.text = "PIN"
      stateLabel.textColor = theWindow.tintColor
      stateLabel.layer.borderColor = theWindow.tintColor.cgColor
      stateLabel.layer.borderWidth = 1
      stateLabel.backgroundColor = .white

      subtitleLabel.textColor = .white

      contentView.layer.insertSublayer(focusGradientLayer, at: 0)

    case MenuItemState.goodToGo:
      stateAlpha = 1

      selectionStyle = .default

      titleLabel.isAutoTintEnabled = true
      titleLabel.textColor = theWindow.tintColor
      titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)

      stateLabel.text = "Go!"
      stateLabel.textColor = .white
      stateLabel.backgroundColor = theWindow.tintColor
      stateLabel.layer.borderWidth = 0
      stateLabel.backgroundColor = theWindow.tintColor

      subtitleLabel.textColor = .lightGray

      focusGradientLayer.removeFromSuperlayer()

    default:
      fatalError()
    }

    stateLabel.alpha = stateAlpha

    if item.state == .workingInProcess {
      stateLabel.alpha -= 0.2
    }
  }

  override func layoutSubviews() {
    focusGradientLayer.frame = bounds
  }
}
