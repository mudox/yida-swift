//
//  ScrollViewTask3ViewController.swift
//  Main
//
//  Created by Mudox on 13/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class ScrollViewTask3ViewController: UIViewController {

  @IBOutlet weak var scrollView: ShowcaseView!

  override func viewDidLoad() {
    super.viewDidLoad()

    setupScrollViews()
  }

  func setupScrollViews() {

    // there are 5 columns
    let columnPages: [ShowcaseView] = (0..<5).map { col in

      // each column has 4 zooming scroll view
      let zoomingPages: [CenteredZoomOutScrollView] = (0..<4).map { row in

        let image = PlaceholderImageSource.anImage(
          ofSize: self.view.bounds.size,
          text: "\(row) - \(col)",
          maxFontPoint: 80
        )
        let imageView = UIImageView(image: image)
        return CenteredZoomOutScrollView(contentView: imageView)
      }

      let columnPageView = ShowcaseView(pageViews: zoomingPages)!
      columnPageView.isContentAnimatingEnabled = false
      columnPageView.scrollingDirection = .vertical

      return columnPageView
    }

    scrollView.pageViews = columnPages
    scrollView.isContentAnimatingEnabled = false
  }
}
