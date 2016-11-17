//
//  SlideInPresentationManager.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 11/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

enum PresentationDirection {
  case top, bottom, left, right, center
}

class SlideInPresentationManager: NSObject {

  var direction = PresentationDirection.left
  var adaptToLandscape = false
  var embedInNavigationControllerOnAdaption = false

}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    let controller = SlideInPresentationController(presentedViewController: presented, presenting: presenting, direction: direction)
    controller.delegate = self
    return controller
  }

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInAnimator(direction: direction, isPresentation: true)
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInAnimator(direction: direction, isPresentation: false)
  }
}

extension SlideInPresentationManager : UIAdaptivePresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    Jack.debug("▣")
    if adaptToLandscape {
      if traitCollection.verticalSizeClass == .compact {
        return .fullScreen
      }
    }

    return .none
  }

  func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
    Jack.debug("▣")
    if embedInNavigationControllerOnAdaption {
      let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
      navigationController.title = "Adaptive Navigation Controller"
      return navigationController
    }

    return nil
  }

}
