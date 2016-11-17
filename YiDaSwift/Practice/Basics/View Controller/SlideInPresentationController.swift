//
//  SlideInPresentationController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 11/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {

  fileprivate var dimmingView: UIView!
  private var direction: PresentationDirection

  init(presentedViewController: UIViewController,
       presenting presentingViewController: UIViewController?,
       direction: PresentationDirection) {

    self.direction = direction
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

    setupDimmingView()
  }


  // install chrome view along with presentation transition if possible
  override func presentationTransitionWillBegin() {Jack.debug("▣")
    containerView?.insertSubview(dimmingView, at: 0)

    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))

    if let coordinator = presentedViewController.transitionCoordinator {
      coordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = 1
        }, completion: nil)
    } else {
      dimmingView.alpha = 1
    }
  }

  // tear down chrome view along with dismissal transition if possible
  override func dismissalTransitionWillBegin() {Jack.debug("▣")
    // dismissal transition fired because of tansition ot use adaptive presentatioin style
    // the cooridnator will be nil, means the tear of current presentation controller happens
    // immediately
    if let coordinator = presentedViewController.transitionCoordinator {
      coordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = 0
        }, completion: nil)
    } else {
      dimmingView.alpha = 0
    }
  }

  override func dismissalTransitionDidEnd(_ completed: Bool) {
    dimmingView.removeFromSuperview()
  }


  // manage size of presented view
  override func size(forChildContentContainer container: UIContentContainer,
                     withParentContainerSize parentSize: CGSize) -> CGSize {
    switch direction {
    case .left, .right:
      return CGSize(width: parentSize.width * (2.0 / 3.0), height: parentSize.height)
    case .top, .bottom:
      return CGSize(width: parentSize.width, height: parentSize.height * (2.0 / 3.0))
    case .center:
      return CGSize(width: 240, height: 160)
    }
  }

  // manage position of presented view
  override var frameOfPresentedViewInContainerView: CGRect {Jack.debug("▣")
    var frame = CGRect.zero
    frame.size = size(forChildContentContainer: presentedViewController,
                      withParentContainerSize: containerView!.bounds.size)

    switch direction {
    case .bottom:
      frame.origin.y = containerView!.bounds.height * (1.0 / 3.0)
    case .right:
      frame.origin.x = containerView!.bounds.width * (1.0 / 3.0)
    case .center:
      frame.origin.x = (containerView!.bounds.width - frame.width) / 2
      frame.origin.y = (containerView!.bounds.height - frame.height) / 2
    default:
      frame.origin = .zero
    }

    return frame
  }

  override func containerViewWillLayoutSubviews() {Jack.debug("▣")
    presentedView!.frame = frameOfPresentedViewInContainerView
  }
}

extension SlideInPresentationController {
  func setupDimmingView() {

    dimmingView = UIView()
    dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
    dimmingView.alpha = 0

    dimmingView.accessibilityIdentifier = "dimmingView"

    dimmingView.translatesAutoresizingMaskIntoConstraints = false

    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }

  dynamic func handleTap(recognizer: UITapGestureRecognizer) {
    presentedViewController.dismiss(animated: true, completion: nil)
  }
}
