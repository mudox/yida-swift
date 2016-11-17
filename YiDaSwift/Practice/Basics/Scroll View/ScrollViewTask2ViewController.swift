//
//  ScrollViewTask2ViewController.swift
//  Main
//
//  Created by Mudox on 12/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class ScrollViewTask2ViewController: UIViewController {

	@IBOutlet weak var scrollView: ShowcaseView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let imageViews: [UIImageView] = (0..<8).map {
			let image = PlaceholderImageSource.anImage(
				ofSize: scrollView.bounds.size,
				text: "\($0)",
				maxFontPoint: CGFloat.infinity
			)
			return UIImageView(image: image)
		}

		scrollView.pageViews = imageViews
	}
}
