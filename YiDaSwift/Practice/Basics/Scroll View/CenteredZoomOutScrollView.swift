//
//  CenteredZoomOutScrollView.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 30/10/2016.
//  Copyright © 2016 Mudox. All rights reserved
//

import UIKit

fileprivate let jack = Jack.with(levelOfThisFile: .warning)

protocol InternalStateListener {
  func scrollView(_ scrollView: CenteredZoomOutScrollView, internalStateDidChange newState: CenteredZoomOutScrollView.InternalState)
}

/// It is used for showing jiejw=
class CenteredZoomOutScrollView: UIScrollView {

  struct InternalState {
    var contentOffset: CGPoint
    var contentSize: CGSize
    var contentInset: UIEdgeInsets
    var bounds: CGRect

    var contentViewFrame: CGRect?
    var contentViewTransform: CGAffineTransform?

    var isTracking: Bool
    var isDragging: Bool
    var isDecelerating: Bool

    var isZooming: Bool
    var isZoomBouncing: Bool
  }

  var internalStateListener: InternalStateListener?

  var contentView: UIView? {
    didSet {
      oldValue?.removeFromSuperview()
      configureZooming()
    }
  }

  init(contentView: UIView) {
    self.contentView = contentView
    super.init(frame: .zero)
    configureZooming()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  var contentViewTopConstraint: NSLayoutConstraint?
  var contentViewBottomConstraint: NSLayoutConstraint?
  var contentViewLeadingConstraint: NSLayoutConstraint?
  var contentViewTrailingConstraint: NSLayoutConstraint?

  func configureZooming() {
    guard let view = contentView else {
      jack.warn("content view should not be nil")
      return
    }

    maximumZoomScale = 2.5
    minimumZoomScale = 0.5

    delegate = self

    addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false

    // anchor content view's 4 edges to the 4 edges of scroll view's content size
    contentViewTopConstraint = view.topAnchor.constraint(equalTo: topAnchor)
    contentViewBottomConstraint = view.bottomAnchor.constraint(equalTo: bottomAnchor)
    contentViewLeadingConstraint = view.leadingAnchor.constraint(equalTo: leadingAnchor)
    contentViewTrailingConstraint = view.trailingAnchor.constraint(equalTo: trailingAnchor)

    NSLayoutConstraint.activate([
      contentViewTopConstraint!,
      contentViewBottomConstraint!,
      contentViewLeadingConstraint!,
      contentViewTrailingConstraint!,

      // make content view fill the whole scroll view when zooming scale is 1
      view.widthAnchor.constraint(equalTo: widthAnchor),
      view.heightAnchor.constraint(equalTo: heightAnchor),
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    // report states change to listerner if any
    if let listener = internalStateListener {
      let state = InternalState(
        contentOffset: contentOffset,
        contentSize: contentSize,
        contentInset: contentInset,
        bounds: bounds,
        contentViewFrame: contentView?.frame,
        contentViewTransform: contentView?.transform,

        isTracking: isTracking,
        isDragging: isDragging,
        isDecelerating: isDecelerating,
        isZooming: isZooming,
        isZoomBouncing: isZoomBouncing
      )
      listener.scrollView(self, internalStateDidChange: state)
    }

    // zoomScale is always in sync with transform scale factor if the transform is not nil (identify)
    if zoomScale != contentView?.transform.a {
      jack.info("zoomScale: \(zoomScale) != contentView.transform.a (\(contentView?.transform.a))")
    }
  }
}

extension CenteredZoomOutScrollView: UIScrollViewDelegate {

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return contentView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    updateContraintsToCenterContentWhenZoomedOut()
  }

  // MARK: Use autolayout to center content if zoomed out
  func updateContraintsToCenterContentWhenZoomedOut() {
    guard contentView != nil else {
      jack.warn("content view should not be nil")
      return
    }

    var horizontalPadding = (bounds.width - contentSize.width) / 2
    if horizontalPadding < 0 { horizontalPadding = 0 }

    var verticalPadding = (bounds.height - contentSize.height) / 2
    if verticalPadding < 0 { verticalPadding = 0 }

    contentViewLeadingConstraint?.constant = horizontalPadding
    contentViewTrailingConstraint?.constant = horizontalPadding

    contentViewTopConstraint?.constant = verticalPadding
    contentViewBottomConstraint?.constant = verticalPadding
  }

  // MARK: Center content if zoomed out not using auto layout
  func centerContentWhenZoomedOutWithoutAutolayout() {
    guard let view = contentView else {
      return
    }

    let xOffset = (bounds.width > contentSize.width)
      ? (bounds.width - contentSize.width) * 0.5: 0.0

    let yOffset = bounds.height > contentSize.height
      ? (bounds.height - contentSize.height) * 0.5: 0.0

    view.center = CGPoint(
      x: contentSize.width * 0.5 + xOffset,
      y: contentSize.height * 0.5 + yOffset
    )
  }
}

