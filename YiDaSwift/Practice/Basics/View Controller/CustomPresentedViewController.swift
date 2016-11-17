//
//  CustomPresentedViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 12/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class CustomPresentedViewController: UIViewController {

  /// a label to show tip how to dismiss itself
  @IBOutlet weak var labelView: UILabel!
  var labelText = "点击灰暗区域撤下本视图"

  /// round corner when slide to center
  var direction = PresentationDirection.center

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    labelView.text = labelText

    let backItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(bye))
    navigationItem.leftBarButtonItem = backItem
  }

  func bye() {
    dismiss(animated: true, completion: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if direction == .center {
      view.layer.cornerRadius = 4
    } else {
      view.layer.cornerRadius = 0
    }

    labelView.alpha = 0

    Jack.verbose("\ncoordinator: \(self.transitionCoordinator)")
  }

  override func viewDidAppear(_ animated: Bool) {Jack.debug("▣")
    super.viewDidAppear(animated)

    UIView.animate(withDuration: 0.15) {
      self.labelView.alpha = 1
    }

    Jack.verbose("\ncoordinator: \(self.transitionCoordinator)")
  }

  override func viewWillDisappear(_ animated: Bool) {Jack.debug("▣")
    super.viewWillDisappear(animated)

    labelView.alpha = 0
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {Jack.debug("▣")
    // change label text shown in new collection
    if navigationController != nil {
      labelView.text = "点击左上角导航栏按钮以撤下本视图"
    } else if newCollection.verticalSizeClass == .compact {
      labelView.text = "请先旋转设备回到竖屏界面，才能撤下本视图"
    } else {
      labelView.text = labelText
    }

    // hide label view before transition
    labelView.alpha = 0

    // animate label view in after transition
    coordinator.animate(alongsideTransition: nil, completion: { _ in
      UIView.animate(withDuration: 0.15, animations: {
        self.labelView.alpha = 1
      })
    })
  }

}
