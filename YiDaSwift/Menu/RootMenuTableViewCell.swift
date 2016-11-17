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

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	func setup(withMenuItem item: MenuItem) {
		titleLabel.text = item.title
		subtitleLabel.text = item.subtitle
		accessibilityIdentifier = item.viewControllerReferenceID

		if !item.isAvailable {
			selectionStyle = .none
			accessoryType = .none

			titleLabel.isEnabled = false

			stateLabel.isHidden = false
			stateLabel.transform = CGAffineTransform(rotationAngle: -45.0 * CGFloat(M_PI) / 180.0)
			stateLabel.layer.cornerRadius = 3
			stateLabel.layer.masksToBounds = true

		} else {
			selectionStyle = .default
			accessoryType = .disclosureIndicator

			titleLabel.isEnabled = true

			stateLabel.isHidden = true
		}
	}
}
