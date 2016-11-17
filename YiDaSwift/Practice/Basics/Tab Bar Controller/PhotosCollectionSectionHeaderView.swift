//
//  PhotosCollectionHeaderView.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 28/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class PhotosCollectionSectionHeaderView: UICollectionReusableView {
	static let identifer = "Photos Collection Section Header View"
	@IBOutlet weak var headerLabel: UILabel!

	override func tintColorDidChange() {
		headerLabel?.textColor = tintColor
	}
}
