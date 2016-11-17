//
//  ShowcaseView.swift
//  Main
//
//  Created by Mudox on 12/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

fileprivate let jack = Jack.with(levelOfThisFile: .warning)

/** 
 # Usage:

 ```swift
 let view = Showcase(pageViews: ...)
 // or init from storyboard

 view.scrollDirection = .horizontal or .vertical
 view.pagesViews = ... // you change page views at any time
 ```

 */
class ShowcaseView: UIScrollView {

  var contentView = UIStackView()
  var middleTileIndex = 0

  // MARK: init & deinit

  deinit {
    jack.debug("Bye!")
  }

  func initSelf() {
    isPagingEnabled = true
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    delegate = self

    initContentView()
  }

  init?(pageViews: [UIView]) {
    guard pageViews.count > 3 else {
      jack.error("page view count (\(pageViews.count)) should be greater than 3")
      return nil
    }

    self.pageViews = pageViews

    super.init(frame: .zero)

    initSelf()
    reloadPageViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    initSelf()
  }

  var contentViewHorizontalConstraints: [NSLayoutConstraint]!
  var contentViewVerticalConstraints: [NSLayoutConstraint]!

  // only called by initSelf()
  func initContentView() {
    // scroll view content view
    contentView.axis = scrollingDirection
    contentView.distribution = .fillEqually
    contentView.alignment = .fill

    addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false

    // anchor all edges to those of content size space
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    // by adjust those constraints' priorities, we can change scrolling direction
    contentViewHorizontalConstraints = [
      contentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 3),
      contentView.heightAnchor.constraint(equalTo: heightAnchor),
    ]

    contentViewVerticalConstraints = [
      contentView.widthAnchor.constraint(equalTo: widthAnchor),
      contentView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 3),
    ]

    NSLayoutConstraint.activate(contentViewHorizontalConstraints)
    NSLayoutConstraint.activate(contentViewVerticalConstraints)
  }

  // MARK: scrolling direction control
  var scrollingDirection: UILayoutConstraintAxis = .horizontal {
    didSet {
      reloadPageViews()
    }
  }

  // only called by reloadPageViews()
  func setupScrollingDirection() {
    contentView.axis = scrollingDirection

    switch scrollingDirection {
    case .horizontal:
      contentViewHorizontalConstraints.forEach {
        $0.priority = 1000
      }
      contentViewVerticalConstraints.forEach {
        $0.priority = 999
      }
    case .vertical:
      contentViewHorizontalConstraints.forEach {
        $0.priority = 999
      }
      contentViewVerticalConstraints.forEach {
        $0.priority = 1000
      }
    }
  }

  // MARK: page view management
  /// the number of pageViews must be greater than 3
  var pageViews: [UIView]! {
    didSet {
      guard pageViews != nil && pageViews.count > 3 else {
        fatalError()
      }

      reloadPageViews()
    }
  }

  func reloadPageViews() {
    guard pageViews != nil && pageViews.count > 3 else {
      return
    }

    suppressContentCircling = true
    suppressContentAnimation = true

    // clear all existing page views
    for _ in 0 ..< contentView.arrangedSubviews.count {
      let page = contentView.arrangedSubviews[0]
      contentView.removeArrangedSubview(page)
      page.removeFromSuperview()
    }

    // install number count - 1, 0, 1 page view
    for i in 0 ..< 3 {
      let page = pageViews[(i - 1 + pageViews.count) % pageViews.count]
      contentView.addArrangedSubview(page)
    }

    setupScrollingDirection()

    // reset contentOffset & middleTileIndex
    middleTileIndex = 0

    switch scrollingDirection {
    case .horizontal:
      contentOffset = CGPoint(x: bounds.width, y: 0)
    case .vertical:
      contentOffset = CGPoint(x: 0, y: bounds.height)
    }

    suppressContentCircling = false
    suppressContentAnimation = false

    startANewContentAnimationCircleIfEnabled()
  }

  // MARK: Animation & Circling

  // animtion timer & animation paramters
  var contentAnimationTimer: Timer?
  var contentAnimationInterval: TimeInterval = 2.5
  var contentAnimationDuration: TimeInterval = 0.3

  // suprress temporarily wether user want or not
  var suppressContentAnimation = false
  var suppressContentCircling = false

  // let user control animation & circling
  var isContentCirclingEnabled = true
  var isContentAnimatingEnabled = true {
    didSet {
      self.startANewContentAnimationCircleIfEnabled()
    }
  }

  func startANewContentAnimationCircleIfEnabled() {
    contentAnimationTimer?.invalidate()

    guard superview != nil else {
      jack.warn("self is detached from super view, invalidate the timer")
      return
    }

    guard isContentAnimatingEnabled && !suppressContentAnimation else {
      return
    }

    contentAnimationTimer = Timer.scheduledTimer(
      timeInterval: contentAnimationInterval,
      target: self,
      selector: #selector(animationTimerFired(timer:)),
      userInfo: nil,
      repeats: false
    )
  }

  func animationTimerFired(timer: Timer) {
    guard superview != nil else {
      jack.warn("self is detached from super view, invalidate the timer")
      contentAnimationTimer?.invalidate()
      return
    }

    guard isContentAnimatingEnabled else {
      return
    }

    // restore after the scrolling animation is done
    suppressContentCircling = true
    UIView.animate(
      withDuration: contentAnimationDuration,
      delay: 0,
      options: [.curveEaseInOut],
      animations: {
        [weak weakSelf = self] in
        if let me = weakSelf {
          switch me.scrollingDirection {
          case .horizontal:
            me.contentOffset = CGPoint(x: 2 * me.bounds.width, y: 0)
          case .vertical:
            me.contentOffset = CGPoint(x: 0, y: 2 * me.bounds.height)
          }
        } else {
          jack.verbose("self deinit'ed, cease animation")
        }
      }, completion: {
        [weak weakSelf = self] success in
        if let me = weakSelf {
          me.suppressContentCircling = false
          me.circleContentIfNeeded()
          me.startANewContentAnimationCircleIfEnabled()
        } else {
          jack.verbose("self deinit'ed, cease animation completion block")
        }
      }
    )
  }

  func circleContentIfNeeded() {
    guard isContentCirclingEnabled && !suppressContentCircling else {
      return
    }

    guard pageViews.count > 3 else {
      return
    }

    if scrollingDirection == .horizontal {
      circleContentHorizontallyIfNeeded()
    } else {
      circleContentVerticallyIfNeeded()
    }
  }

  func circleContentVerticallyIfNeeded() {

    let tileHeight = bounds.height
    let offsetY = contentOffset.y + tileHeight * 0.5
    let centerY = 1.5 * tileHeight

    if offsetY > centerY { // scrolling to bottom edge

      let distanceToEdge = 3 * tileHeight - (offsetY + 0.5 * tileHeight)
      if distanceToEdge < 0.5 * tileHeight {

        // remove top tile's content
        let topTile = contentView.arrangedSubviews.first!
        contentView.removeArrangedSubview(topTile)
        topTile.removeFromSuperview()

        // load with next image
        let newTileIndex = (middleTileIndex + 2) % pageViews.count
        let newTile = pageViews[newTileIndex]

        // move the top tile to bottom most
        contentView.addArrangedSubview(newTile)

        // rewind bounds back a tile height
        contentOffset.y -= tileHeight

        // update index
        middleTileIndex = (middleTileIndex + 1) % pageViews.count

        jack.debug("circle content to next: [top, \(middleTileIndex), bottom]")
      }

    } else { // scrolling to top edge

      let distanceToEdge = offsetY - 0.5 * tileHeight
      if distanceToEdge < 0.5 * tileHeight {

        // remove bottom tile's content
        let bottomTile = contentView.arrangedSubviews.last!
        contentView.removeArrangedSubview(bottomTile)
        bottomTile.removeFromSuperview()

        // load with next image
        let newTileIndex = (middleTileIndex - 2 + pageViews.count) % pageViews.count
        let newTile = pageViews[newTileIndex]

        // move the bottom tile to bottom most
        contentView.insertArrangedSubview(newTile, at: 0)

        // rewind bounds back a tile height
        contentOffset.y += tileHeight

        // update index
        middleTileIndex = (middleTileIndex - 1 + pageViews.count) % pageViews.count

        jack.debug("circle content to previous: [top, \(middleTileIndex), bottom]")
      }
    }
  }

  func circleContentHorizontallyIfNeeded() {

    let tileWidth = bounds.width
    let offsetX = contentOffset.x + tileWidth * 0.5
    let centerX = 1.5 * tileWidth

    if offsetX > centerX { // scrolling to right edge

      let distanceToEdge = 3 * tileWidth - (offsetX + 0.5 * tileWidth)
      if distanceToEdge < 0.5 * tileWidth {

        // remove left tile's content
        let leftTile = contentView.arrangedSubviews.first!
        contentView.removeArrangedSubview(leftTile)
        leftTile.removeFromSuperview()

        // load with next image
        let newTileIndex = (middleTileIndex + 2) % pageViews.count
        let newTile = pageViews[newTileIndex]

        // move the left tile to right most
        contentView.addArrangedSubview(newTile)

        // rewind bounds back a tile width
        contentOffset.x -= tileWidth

        // update index
        middleTileIndex = (middleTileIndex + 1) % pageViews.count

        jack.debug("circle content to next: [left, \(middleTileIndex), right]")
      }

    } else { // scrolling to left edge

      let distanceToEdge = offsetX - 0.5 * tileWidth
      if distanceToEdge < 0.5 * tileWidth {

        // remove right tile's content
        let rightTile = contentView.arrangedSubviews.last!
        contentView.removeArrangedSubview(rightTile)
        rightTile.removeFromSuperview()

        // load with next image
        let newTileIndex = (middleTileIndex - 2 + pageViews.count) % pageViews.count
        let newTile = pageViews[newTileIndex]

        // move the right tile to right most
        contentView.insertArrangedSubview(newTile, at: 0)

        // rewind bounds back a tile width
        contentOffset.x += tileWidth

        // update index
        middleTileIndex = (middleTileIndex - 1 + pageViews.count) % pageViews.count

        jack.debug("circle content to previous: [left, \(middleTileIndex), right]")
      }
    }
  }
}

// MARK: - as UIScrollViewDelegate
extension ShowcaseView: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    circleContentIfNeeded()
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    jack.verbose("stop content animation")

    suppressContentAnimation = true
    contentAnimationTimer?.invalidate()
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      jack.verbose("dragging ends without deceleration, restore content animation")
      suppressContentAnimation = false
      startANewContentAnimationCircleIfEnabled()
    } else {
      jack.verbose("dragging ends with deceleration, suppress animation until deceleration is over")
    }
  }

  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    jack.verbose("nothing to do")
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    jack.verbose("restore content animation")
    suppressContentAnimation = false
    startANewContentAnimationCircleIfEnabled()
  }
}
