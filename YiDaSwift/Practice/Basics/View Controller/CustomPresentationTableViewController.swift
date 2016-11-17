//
//  CustomPresentationTableViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 12/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class CustomPresentationTableViewController: UITableViewController {

  // slide in presentation
  @IBOutlet weak var slideInDirectionSegmentedControl: UISegmentedControl!
  lazy var slideInTransitioningDelegate = SlideInPresentationManager()

  // adaption
  @IBOutlet weak var adaptToLandscapeSwitch: UISwitch!
  @IBOutlet weak var embedInNavigationControllerSwitch: UISwitch!
  @IBOutlet weak var embedInNavigationControllerLabel: UILabel!

  // MARK: - as UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    slideInDirectionSegmentedControl.accessibilityIdentifier = "slideInPresentation"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.

    switch segue.destination {
    case let vc as CustomPresentedViewController:
      switch segue.identifier! {
      case "Slide From Top":
        slideInTransitioningDelegate.direction = .top
        vc.labelText = "点击下方的灰暗区域撤下本视图"
      case "Slide From Bottom":
        slideInTransitioningDelegate.direction = .bottom
        vc.labelText = "点击上方的灰暗区域撤下本视图"
      case "Slide From Left":
        slideInTransitioningDelegate.direction = .left
        vc.labelText = "点击右侧的灰暗区域撤下本视图"
      case "Slide From Right":
        slideInTransitioningDelegate.direction = .right
        vc.labelText = "点击左侧的灰暗区域撤下本视图"
      case "Slide To Center":
        slideInTransitioningDelegate.direction = .center
        vc.labelText = "点击周围的灰暗区域撤下本视图"
      default:
        assertionFailure()
      }

      vc.direction = slideInTransitioningDelegate.direction

      vc.modalPresentationStyle = .custom
      vc.transitioningDelegate = slideInTransitioningDelegate
    default:
      assertionFailure()
    }
  }

  // MARK: - Actions

  @IBAction func slideInSegmentedControlValueChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      performSegue(withIdentifier: "Slide From Left", sender: self)
    case 1:
      performSegue(withIdentifier: "Slide From Top", sender: self)
    case 2:
      performSegue(withIdentifier: "Slide To Center", sender: self)
    case 3:
      performSegue(withIdentifier: "Slide From Bottom", sender: self)
    case 4:
      performSegue(withIdentifier: "Slide From Right", sender: self)
    default:
      assertionFailure()
    }
  }

  @IBAction func adaptToLandscapeChanged(_ sender: UISwitch) {
    slideInTransitioningDelegate.adaptToLandscape = sender.isOn
    embedInNavigationControllerLabel.isEnabled = sender.isOn
    embedInNavigationControllerSwitch.isEnabled = sender.isOn
  }

  @IBAction func embedInNavigationControllerChanged(_ sender: UISwitch) {
    slideInTransitioningDelegate.embedInNavigationControllerOnAdaption = sender.isOn
  }
}
