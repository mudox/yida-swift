/// /  CustomNavigationControllerViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 05/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class CustomNavigationControllerTableViewController: UITableViewController {

  var navigationBar: UINavigationBar {
    return navigationController.navigationBar
  }

  var toolbar: UIToolbar {
    return navigationController.toolbar
  }
  
  override var navigationController: RootNavigationController {
    return super.navigationController as! RootNavigationController
  }
  
  @IBOutlet weak var promptSwitch: UISwitch!
  @IBOutlet weak var navbarStyleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var navbarBackgroundSegmentedControl: UISegmentedControl!
  @IBOutlet weak var navbarTitleSegmentedControl: UISegmentedControl!

  // left bar button item
  @IBOutlet weak var navbarLeftButtonItemStyleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var navbarLeftButtonItemCountSegmentedControl: UISegmentedControl!

  @IBOutlet weak var navbarHideBackButtonSwitch: UISwitch!
  @IBOutlet weak var navbarCoexistsWithBackButtonSwitch: UISwitch!

  // right bar button item
  @IBOutlet weak var navbarRightButtonItemStyleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var navbarRightButtonItemCountSegmentedControl: UISegmentedControl!

  // tool bar
  @IBOutlet weak var toolbarStyleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var toolbarBackgroundSegmentedControl: UISegmentedControl!
  @IBOutlet weak var toolbarItemStyleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var toolbarItemLayoutSegmentedControl: UISegmentedControl!

  // MARK: - Actions
  enum navbarItemSide {
    case leftSide, rightSide
  }

  lazy var barButtonItems = initBarButtonItems()

  func updateNavbarItems(of side: navbarItemSide) {
    let itemCount = (side == .leftSide)
      ? navbarLeftButtonItemCountSegmentedControl.selectedSegmentIndex
      : navbarRightButtonItemCountSegmentedControl.selectedSegmentIndex

    let index = (side == .leftSide)
      ? navbarLeftButtonItemStyleSegmentedControl.selectedSegmentIndex
      : navbarRightButtonItemStyleSegmentedControl.selectedSegmentIndex

    if itemCount == 0 {
      if side == .leftSide {
        navigationItem.setLeftBarButtonItems(nil, animated: true)
      } else {
        navigationItem.setRightBarButtonItems(nil, animated: true)
      }
    } else {
      let itemsToAdd = [UIBarButtonItem](barButtonItems[side]![index][0 ..< itemCount])

      if side == .leftSide {
        navigationItem.setLeftBarButtonItems(itemsToAdd, animated: true)
      } else {
        navigationItem.setRightBarButtonItems(itemsToAdd, animated: true)
      }
    }
  }

  // MARK: Customize navigation bar

  @IBAction func promptSwitchChanged(_ sender: UISwitch) {
    if sender.isOn {
      navigationItem.prompt = "宜达互联 SWIFT"
    } else {
      navigationItem.prompt = nil
    }
  }

  @IBAction func navbarStyleChanged(_ sender: UISegmentedControl) {
    // bar style setting will be overriden by background setting
    navbarBackgroundSegmentedControl.selectedSegmentIndex = 0
    navbarBackgroundChanged(navbarBackgroundSegmentedControl)

    switch sender.selectedSegmentIndex {
    case 0: // default
      navigationController.statusBarStyle = .default
      navigationBar.barStyle = .default
      navigationBar.tintColor = nil
    case 1: // black
      navigationController.statusBarStyle = .lightContent
      navigationBar.barStyle = .black
      navigationBar.tintColor = .white
    default:
      assertionFailure()
    }

    updateNavbarItems(of: .leftSide)
    updateNavbarItems(of: .rightSide)
  }

  @IBAction func navbarBackgroundChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {

    case 0: // default
      navigationBar.setBackgroundImage(nil, for: .default)

      navigationController.statusBarStyle = .default
      navigationBar.barTintColor = nil
      navigationBar.tintColor = (navigationBar.barStyle == .default) ? nil : .white
      navigationBar.titleTextAttributes = nil

    case 1: // color background
      navigationBar.setBackgroundImage(nil, for: .default)

      navigationController.statusBarStyle = .lightContent
      navigationBar.tintColor = .white
      navigationBar.barTintColor = theWindow.tintColor
      navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

    case 2: // image background
      navigationController.statusBarStyle = .lightContent
      navigationBar.tintColor = .white
      navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
      navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Navbar"), for: .default)

    default:
      assertionFailure()
    }

    updateNavbarItems(of: .leftSide)
    updateNavbarItems(of: .rightSide)
  }

  @IBAction func navbarTitleChanged(_ sender: UISegmentedControl) {

    switch sender.selectedSegmentIndex {

    case 0: // text title
      navigationItem.titleView = nil
      navigationItem.title = "标题"

    case 1: // image title
      navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "NavbarTitle"))

    case 2: // custom view
      let control = UISegmentedControl(items: ["左", "右"])
      control.selectedSegmentIndex = 0
      navigationBar.setTitleVerticalPositionAdjustment(-1, for: .default)
      navigationItem.titleView = control

    default:
      assertionFailure()
    }
  }

  @IBAction func navbarLeftButtonItemStyleChanged(_ sender: UISegmentedControl) {
    if navbarLeftButtonItemStyleSegmentedControl.selectedSegmentIndex == 0 {
      if navbarLeftButtonItemCountSegmentedControl.selectedSegmentIndex > 1 {
        navbarLeftButtonItemCountSegmentedControl.selectedSegmentIndex = 1
      }
      navbarLeftButtonItemCountSegmentedControl.setEnabled(false, forSegmentAt: 2)
    } else {
      navbarLeftButtonItemCountSegmentedControl.setEnabled(true, forSegmentAt: 2)
    }

    updateNavbarItems(of: .leftSide)
  }

  @IBAction func navbarLeftButtonItemCountChanged(_ sender: UISegmentedControl) {
    updateNavbarItems(of: .leftSide)
  }

  @IBAction func navbarHideBackButtonChanged(_ sender: UISwitch) {
    guard (navigationItem.leftItemsSupplementBackButton
      && navigationItem.leftBarButtonItems != nil)
      || navigationItem.leftBarButtonItems == nil else {
      return
    }

    navigationItem.setHidesBackButton(sender.isOn, animated: true)
  }

  @IBAction func navbarCoexistsWithBackButtonChanged(_ sender: UISwitch) {
    navigationItem.leftItemsSupplementBackButton = sender.isOn
  }

  @IBAction func navbarRightBarButtonItemCountChanged(_ sender: UISegmentedControl) {
    updateNavbarItems(of: .rightSide)
  }

  @IBAction func navRightBarButtonItemStyleChanged(_ sender: UISegmentedControl) {
    if navbarRightButtonItemStyleSegmentedControl.selectedSegmentIndex == 0 {
      if navbarRightButtonItemCountSegmentedControl.selectedSegmentIndex > 1 {
        navbarRightButtonItemCountSegmentedControl.selectedSegmentIndex = 1
      }
      navbarRightButtonItemCountSegmentedControl.setEnabled(false, forSegmentAt: 2)
    } else {
      navbarRightButtonItemCountSegmentedControl.setEnabled(true, forSegmentAt: 2)
    }

    updateNavbarItems(of: .rightSide)
  }

  // MARK: Customize tool bar

  lazy var toolbarButtonItems = inittoolbarBarButtonItems()

  private func updateToolbarItems() {
    var items = [UIBarButtonItem](toolbarButtonItems[toolbarItemStyleSegmentedControl.selectedSegmentIndex])
    let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    fixedSpace.width = 5
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    switch toolbarItemLayoutSegmentedControl.selectedSegmentIndex {
    case 0:
      items.insert(flexibleSpace, at: 0)
      items.insert(flexibleSpace, at: 2)
      items.insert(flexibleSpace, at: 4)
      items.insert(flexibleSpace, at: 6)
    case 1:
      items.insert(fixedSpace, at: 0)
      items.insert(flexibleSpace, at: 2)
      items.insert(flexibleSpace, at: 4)
      items.insert(fixedSpace, at: 6)
    case 2:
      items.insert(flexibleSpace, at: 0)
      items.insert(fixedSpace, at: 2)
      items.insert(fixedSpace, at: 4)
      items.append(flexibleSpace)
    default:
      assertionFailure()
    }
    setToolbarItems(items, animated: true)
  }

  @IBAction func toolbarStyleChanged(_ sender: UISegmentedControl) {
    toolbarBackgroundSegmentedControl.selectedSegmentIndex = 0
    toolbarBackgroundChanged(toolbarBackgroundSegmentedControl)

    switch sender.selectedSegmentIndex {
    case 0: // default
      toolbar.barStyle = .default
      toolbar.tintColor = nil
    case 1: // black
      toolbar.barStyle = .black
      toolbar.tintColor = .white
    default:
      assertionFailure()
    }

    updateToolbarItems()
  }

  @IBAction func toolbarBackgroundChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: // default
      toolbar.tintColor = nil
      toolbar.barTintColor = nil
      toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)

    case 1: // color
      toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
      toolbar.barTintColor = theWindow.tintColor
      toolbar.tintColor = .white

    case 2:
      toolbar.tintColor = .white
      toolbar.setBackgroundImage(#imageLiteral(resourceName: "Toolbar"), forToolbarPosition: .any, barMetrics: .default)

    default:
      assertionFailure()
    }

    updateToolbarItems()
  }

  @IBAction func toolbarItemStyleChanged(_ sender: UISegmentedControl) {
    updateToolbarItems()
  }

  @IBAction func toolbarItemLayoutChanged(_ sender: UISegmentedControl) {
    updateToolbarItems()
  }

  // MARK: - as UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    // UI testable
    promptSwitch.accessibilityIdentifier = "prompt"

    navbarStyleSegmentedControl.accessibilityIdentifier = "navbarStyle"
    navbarBackgroundSegmentedControl.accessibilityIdentifier = "navbarBackground"
    navbarTitleSegmentedControl.accessibilityIdentifier = "navTitle"

    navbarLeftButtonItemStyleSegmentedControl.accessibilityIdentifier = "navLeftBarButtonItemStyle"
    navbarLeftButtonItemCountSegmentedControl.accessibilityIdentifier = "navLeftBarButtonItemCount"
    navbarRightButtonItemStyleSegmentedControl.accessibilityIdentifier = "navRightBarButtonItemStyle"
    navbarRightButtonItemCountSegmentedControl.accessibilityIdentifier = "navRightBarButtonItemCount"
    navbarHideBackButtonSwitch.accessibilityIdentifier = "hidesBackButton"
    navbarCoexistsWithBackButtonSwitch.accessibilityIdentifier = "coexistsWithBackButton"

    toolbarStyleSegmentedControl.accessibilityIdentifier = "toolbarStyle"
    toolbarBackgroundSegmentedControl.accessibilityIdentifier = "toolbarBackground"
    toolbarItemStyleSegmentedControl.accessibilityIdentifier = "toolbarItemStyle"
    toolbarItemLayoutSegmentedControl.accessibilityIdentifier = "toolbarItemLayout"
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // update navigation bar appearence
    promptSwitchChanged(promptSwitch)
    navbarBackgroundChanged(navbarBackgroundSegmentedControl)
    navbarTitleChanged(navbarTitleSegmentedControl)

    navbarLeftButtonItemStyleChanged(navbarLeftButtonItemStyleSegmentedControl)
    navRightBarButtonItemStyleChanged(navbarRightButtonItemStyleSegmentedControl)

    // update tool bar appearence
    navigationController.setToolbarHidden(false, animated: true)
    updateToolbarItems()
    toolbarBackgroundChanged(toolbarBackgroundSegmentedControl)
    toolbarItemStyleChanged(toolbarItemStyleSegmentedControl)
    toolbarItemLayoutChanged(toolbarItemLayoutSegmentedControl)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    navigationController.setToolbarHidden(true, animated: false)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

private func initBarButtonItems() -> [CustomNavigationControllerTableViewController.navbarItemSide: [[UIBarButtonItem]]] {
  var items: [CustomNavigationControllerTableViewController.navbarItemSide: [[UIBarButtonItem]]] = [
    CustomNavigationControllerTableViewController.navbarItemSide.leftSide: [
      [
        UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil),
      ],
      [
        UIBarButtonItem(title: "左一", style: .plain, target: nil, action: nil),
        UIBarButtonItem(title: "左二", style: .plain, target: nil, action: nil),
      ],
      [
        UIBarButtonItem(image: #imageLiteral(resourceName: "BarButtonItem-1"), style: .plain, target: nil, action: nil),
        UIBarButtonItem(image: #imageLiteral(resourceName: "BarButtonItem-2"), style: .plain, target: nil, action: nil),
      ],
    ],

    CustomNavigationControllerTableViewController.navbarItemSide.rightSide: [
      [
        UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil),
      ],
      [
        UIBarButtonItem(title: "右一", style: .plain, target: nil, action: nil),
        UIBarButtonItem(title: "右二", style: .plain, target: nil, action: nil),
      ],
      [
        UIBarButtonItem(image: #imageLiteral(resourceName: "BarButtonItem-1"), style: .plain, target: nil, action: nil),
        UIBarButtonItem(image: #imageLiteral(resourceName: "BarButtonItem-2"), style: .plain, target: nil, action: nil),
      ],
    ],
  ]

  var itemList = [UIBarButtonItem]()
  for i in 1 ... 2 {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
    button.setTitle("B\(i)", for: .normal)
    let item = UIBarButtonItem(customView: button)
    itemList.append(item)
  }
  items[.leftSide]!.append(itemList)

  itemList = [UIBarButtonItem]()
  for i in 1 ... 2 {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
    button.setTitle("B\(i)", for: .normal)
    let item = UIBarButtonItem(customView: button)
    itemList.append(item)
  }
  items[.rightSide]!.append(itemList)

  return items
}

private func inittoolbarBarButtonItems() -> [[UIBarButtonItem]] {
  var items: [[UIBarButtonItem]] = []
  // system item
  var sublist = [
    UIBarButtonItem(barButtonSystemItem: .rewind, target: nil, action: nil),
    UIBarButtonItem(barButtonSystemItem: .pause, target: nil, action: nil),
    UIBarButtonItem(barButtonSystemItem: .fastForward, target: nil, action: nil),
  ]
  items.append(sublist)

  // item with title
  sublist = [
    UIBarButtonItem(title: "左边", style: .plain, target: nil, action: nil),
    UIBarButtonItem(title: "中间", style: .plain, target: nil, action: nil),
    UIBarButtonItem(title: "右边", style: .plain, target: nil, action: nil),
  ]
  items.append(sublist)

  // item with image
  sublist = [
    UIBarButtonItem(image: #imageLiteral(resourceName: "BarButtonItem-3"), style: .plain, target: nil, action: nil),
    UIBarButtonItem(image: #imageLiteral(resourceName: "BarButtonItem-4"), style: .plain, target: nil, action: nil),
    UIBarButtonItem(image: #imageLiteral(resourceName: "BarButtonItem-5"), style: .plain, target: nil, action: nil),
  ]
  items.append(sublist)

  // items with custom view
  sublist = []

  var segment = UISegmentedControl(items: ["左一", "左二"])
  segment.selectedSegmentIndex = 0
  sublist.append(UIBarButtonItem(customView: segment))

  let switchControl = UISwitch()
  switchControl.isOn = true
  sublist.append(UIBarButtonItem(customView: switchControl))

  segment = UISegmentedControl(items: ["右二", "右一"])
  segment.selectedSegmentIndex = 1
  sublist.append(UIBarButtonItem(customView: segment))

  items.append(sublist)

  return items
}
