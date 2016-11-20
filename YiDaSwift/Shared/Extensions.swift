//
//  Extensions.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 22/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

// MARK: - UIViewController Dismissable

// if view controller is in a modally presented view controller hierarchy,
// add a bar button item to the left of the navigation bar to dismiss the presentation.
extension UIViewController {
  func installDismissButtonOnNavigationBar() {
    guard presentingViewController != nil &&
    navigationController != nil else {
      Jack.warn("invoked on wrong context")
      return
    }

    let buttonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavIcon-Dismiss-ViewController"), style: .done, target: self, action: #selector(dismiss(sender:)))
    navigationItem.leftBarButtonItem = buttonItem
  }

  func dismiss(sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Pan In AnyWhere To Pop Feature
extension UINavigationController: UIGestureRecognizerDelegate {

  func enablePanInAnywhereToPop() {
    // enable all existing pan gestures if any
    if let gestures = view.gestureRecognizers {
      var found = false
      for gesture in gestures {
        if gesture.isKind(of: UIPanGestureRecognizer.self) &&
        gesture.delegate === self {
          gesture.isEnabled = true
          found = true
        }
      }
      if found { return }
    }

    // if no pan gesture exists, create and configure a new one
    interactivePopGestureRecognizer!.isEnabled = false
    let target = interactivePopGestureRecognizer!.delegate!
    let panGesture = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")))
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)
  }

  func disablePanInAnyWhereToPop() {
    view.gestureRecognizers?.forEach { gesture in
      if gesture.isKind(of: UIPanGestureRecognizer.self) &&
      gesture.delegate === self {
        gesture.isEnabled = false
      }
    }
  }

  func enableEdgePanToPopAlways() {
    interactivePopGestureRecognizer!.delegate = self
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard viewControllers.count > 1 else {
      return false
    }

    // only pan to the right will trigger the transition
    return (gestureRecognizer as! UIPanGestureRecognizer).translation(in: self.view).x > 0
  }
}

extension CGRect {
  var shortDescription: String {
    return NSString(format: "origin(%@) size(%@)", origin.shortDescription, size.shortDescription) as String
  }
}

extension CGPoint {
  var shortDescription: String {
    return NSString(format: "%.02f, %.02f", x, y) as String
  }
}

extension CGSize {
  var shortDescription: String {
    return NSString(format: "%.02f, %.02f", width, height) as String
  }
}

extension CGFloat {
  var shortDescription: String {
    return NSString(format: "%.02f", self) as String
  }
}

extension Float {
  var shortDescription: String {
    return NSString(format: "%.02f", self) as String
  }
}

extension Double {
  var shortDescription: String {
    return NSString(format: "%.02f", self) as String
  }
}
