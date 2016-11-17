//
//  ScrollExercisesTableViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 02/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class ScrollViewTask1ViewController: UIViewController {

  @IBOutlet weak var scrollView: ShowcaseView!

  override func viewDidLoad() {
    super.viewDidLoad()

    scrollView.isContentAnimatingEnabled = false

    let imageViews: [UIImageView] = (0..<8).map {
      let image = PlaceholderImageSource.anImage(
        ofSize: scrollView.bounds.size,
        text: "\($0)",
        maxFontPoint: CGFloat.infinity
      )
      return UIImageView(image: image)
    }

    scrollView.scrollingDirection = .vertical
    scrollView.pageViews = imageViews
  }
}
