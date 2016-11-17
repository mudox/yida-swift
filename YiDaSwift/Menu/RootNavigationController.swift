//
//  RootNavigationController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 23/09/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

/**
 This navigation controller
 - Hand over the interface orientation decision to top content view controller
 - Define a stored property __statusBarStyle__ so user can easily change status bar style by simply setting this property
 */
class RootNavigationController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    enablePanInAnywhereToPop()
  }

  // MARK: Manage status bar
  var statusBarStyle: UIStatusBarStyle = .lightContent {
    didSet {
      setNeedsStatusBarAppearanceUpdate()
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return statusBarStyle
  }

  // MARK: Manage interface orirentation

  // hand over interface orirentation decision to top view controller on the stack
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return topViewController!.preferredInterfaceOrientationForPresentation
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return topViewController!.supportedInterfaceOrientations
  }
}
