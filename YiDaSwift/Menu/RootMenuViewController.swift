//
//  IOSBasicsMenuTableViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 9/20/16.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit
import SwiftyJSON

class RootMenuViewController: UIViewController {

	@IBOutlet weak var expandButton: UIBarButtonItem!

	@IBOutlet weak var basicDiv: UIView!
	@IBOutlet weak var basicButton: UIButton!

	@IBOutlet weak var advancedDiv: UIView!
	@IBOutlet weak var advancedButton: UIButton!

	@IBOutlet weak var frameworkDiv: UIView!
	@IBOutlet weak var frameworkButton: UIButton!

	@IBOutlet var overlayDivs: [UIView]!
	@IBOutlet var overlayButtons: [UIButton]!

	@IBOutlet weak var tableView: UITableView!

	var baseThemeColor: UIColor?

	/// If is nil, the top level menu overlay is expanded to cover the whole space.
	var menuPart: [MenuSection]?
}

// MARK: - Menu Expanding & Shrunking
extension RootMenuViewController {

	@IBAction func partButtonTapped(_ sender: UIButton) {

		let topMostDiv: UIView
		switch sender.tag {
		case 1: // basic
			menuPart = Menu.shared.basicPart
			topMostDiv = basicDiv
			navigationItem.title = "iOS · 基础"
		case 2: // advanced
			menuPart = Menu.shared.advancedPart
			topMostDiv = advancedDiv
			navigationItem.title = "iOS · 进阶"
		case 3: // framework
			menuPart = Menu.shared.frameworkPart
			topMostDiv = frameworkDiv
			navigationItem.title = "iOS · 框架"
		default:
			fatalError()
		}

		baseThemeColor = sender.superview!.backgroundColor
		assert(baseThemeColor != nil)
		theWindow.tintColor = baseThemeColor

		tableView.reloadData()
		tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)

		pullUpMenu(withTopMostDiv: topMostDiv)
	}

	@IBAction func expandButtonTapped(_ sender: UIBarButtonItem) {
		expandMenu()
	}

	func layoutDivsExpanded() {
		var baseFrame = theWindow.bounds
		let divHeight = theWindow.bounds.height / 3
		baseFrame.size.height = divHeight

		basicDiv.frame = baseFrame
		baseFrame.origin.y += divHeight
		advancedDiv.frame = baseFrame
		baseFrame.origin.y += divHeight
		frameworkDiv.frame = baseFrame

		overlayButtons.forEach {
			$0.frame = $0.superview!.bounds
		}
	}

	func layoutDivsShrunk() {
		let baseFrame = CGRect(
			x: 0,
			y: 0,
			width: theWindow.bounds.width,
			height: theApp.statusBarFrame.height + navigationController!.navigationBar.bounds.height
		)

		overlayDivs.forEach {
			$0.frame = baseFrame
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if menuPart == nil {
			layoutDivsExpanded()
		} else {
			layoutDivsShrunk()
		}
	}

	/**
   Expand first level menu to cover the underlying second level practice level
   
   - parameter Animated: animate the expanding or not.
   */
	fileprivate func expandMenu() {

		overlayDivs.forEach {
			theWindow.addSubview($0)
		}

		UIView.animateKeyframes(
			withDuration: 0.25,
			delay: 0,
			options: [],
			animations:
				{
					self.layoutDivsExpanded()
			},
			completion:
				{ _ in
					self.overlayButtons.forEach {
						$0.isHidden = false
					}
			}
		)
	}

	/**
   Pull up first level menu to cover the underlying second level practice level
   
   - parameter Animated: animate the shrinking or not.
   */
	fileprivate func pullUpMenu(withTopMostDiv topDiv: UIView) {
		topDiv.removeFromSuperview()
		theWindow.addSubview(topDiv)

		self.overlayButtons.forEach {
			$0.isHidden = true
		}

		UIView.animate(
			withDuration: 0.25,
			delay: 0,
			options: [.curveEaseIn],
			animations:
				{
					self.layoutDivsShrunk()
			},
			completion:
				{ (success: Bool) in
					self.navigationController!.setNavigationBarHidden(false, animated: false)

					self.overlayDivs.forEach {
						$0.removeFromSuperview()
					}
			}
		)

	}
}

// MARK: - as UIViewController
extension RootMenuViewController {

	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .portrait
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// install overlay divisions
		overlayDivs.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			theWindow.addSubview($0)
		}

		// auto-sizing table view cells
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		theWindow.tintColor = baseThemeColor

		navigationController?.navigationBar.setTheme(with: baseThemeColor)
		navigationController?.toolbar.setTheme(with: baseThemeColor)
		tabBarController?.tabBar.setTheme(with: baseThemeColor)
	}

}

// MARK: - as UITableViewDataSource
extension RootMenuViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return menuPart != nil ? menuPart!.count : 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuPart![section].items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Root Menu Cell", for: indexPath) as! RootMenuTableViewCell

		let item = menuItem(forIndexPath: indexPath)
		cell.setup(withMenuItem: item)

		return cell
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return menuPart![section].headerText
	}
}

// MARK: - as UITableViewDelegate
extension RootMenuViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		let item = menuItem(forIndexPath: indexPath)
		guard item.isAvailable else {
			return
		}

		let storyboard = UIStoryboard(name: item.storyboardName, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: item.viewControllerReferenceID)

		if let presenting = item.presenting {
			switch presenting {
			case "Cross Dissolve":
				viewController.modalTransitionStyle = .crossDissolve
			case "Cover Vertical":
				viewController.modalTransitionStyle = .coverVertical
			case "Flip Horizontal":
				viewController.modalTransitionStyle = .flipHorizontal
			default:
				assertionFailure()
			}

			present(viewController, animated: true, completion: nil)
		} else {
			navigationController?.pushViewController(viewController, animated: true)
		}
	}

	func menuItem(forIndexPath indexPath: IndexPath) -> MenuItem {
		return menuPart![indexPath.section].items[indexPath.row]
	}
}
