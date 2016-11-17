//
//  SlideInAnimator.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 12/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class SlideInAnimator: NSObject {

  let direction: PresentationDirection
  let isPresentation: Bool

  init(direction: PresentationDirection, isPresentation: Bool) {
    self.direction = direction
    self.isPresentation = isPresentation

    super.init()
  }
}

extension SlideInAnimator: UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let presentedViewController = transitionContext.viewController(forKey: isPresentation ? .to : .from)!
    let presentedView = transitionContext.view(forKey: isPresentation ? .to : .from)!

    if isPresentation {
      containerView.addSubview(presentedView)
    }

    // figure out initial & final frame
    let onStageFrame = isPresentation
      ? transitionContext.finalFrame(for: presentedViewController)
      : transitionContext.initialFrame(for: presentedViewController)

    var offStageFrame = onStageFrame

    switch direction {
    case .top:
      offStageFrame.origin.y = -onStageFrame.height
    case .bottom:
      offStageFrame.origin.y = containerView.bounds.maxY
    case .left:
      offStageFrame.origin.x = -onStageFrame.width
    case .right:
      offStageFrame.origin.x = containerView.bounds.maxX
    case .center:
      if isPresentation {
        offStageFrame.origin.y = -onStageFrame.height
      } else {
        offStageFrame.origin.y = containerView.bounds.maxY
      }
    }

    let fromFrame = isPresentation ? offStageFrame : onStageFrame
    let toFrame = isPresentation ? onStageFrame : offStageFrame

    let animationDuration = transitionDuration(using: transitionContext)

    // animate
    presentedView.frame = fromFrame
    presentedView.alpha = isPresentation ? 0 : 1
    if direction == .center {
      presentedView.transform = CGAffineTransform(rotationAngle: CGFloat(180 * (M_PI / 180)))
    }

    if direction == .center {

      UIView.animate(withDuration: animationDuration,
                     delay: 0,
                     usingSpringWithDamping: 0.5,
                     initialSpringVelocity: 0.8,
                     options: [],
                     animations: {
        presentedView.frame = toFrame
        presentedView.transform = .identity
        presentedView.alpha = self.isPresentation ? 1 : 0
      }) { _ in
        transitionContext.completeTransition(true)
      }

    } else {

      UIView.animate(withDuration: animationDuration,
                     delay: 0,
                     options: .curveEaseOut,
                     animations: {
          presentedView.frame = toFrame
          presentedView.transform = .identity
          presentedView.alpha = self.isPresentation ? 1 : 0
        },
                     completion: { _ in
          transitionContext.completeTransition(true)
      })
    }
  }
}
