//
//  AppTheme.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 24/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

fileprivate let jack = Jack.with(levelOfThisFile: .warning)

func initAppTheme() {
	UINavigationBar.appearance().isTranslucent = false
	UIToolbar.appearance().isTranslucent = false
	UITabBar.appearance().isTranslucent = false

	UITextField.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .darkGray
}

extension UIWindow {
	open override func tintColorDidChange() {
		propagateColor(tintColor)
		UINavigationBar.appearance().setTheme(with: tintColor)
		UIToolbar.appearance().setTheme(with: tintColor)
		UITabBar.appearance().setTheme(with: tintColor)
	}
}

extension UIView {
	func propagateColor(_ color: UIColor?) {
		subviews.forEach {
			switch $0 {
			case let navBar as UINavigationBar:
				navBar.setTheme(with: color)
				return
			case let toolBar as UIToolbar:
				toolBar.setTheme(with: color)
				return
			case let tabBar as UITabBar:
				tabBar.setTheme(with: color)
				return
			default:
				break
			}

			$0.propagateColor(color)
		}
	}
}

extension UINavigationBar {
	func setTheme(with color: UIColor?) { jack.debug("▣ \(type(of: self))")
		if let newColor = color {
			setBackgroundImage(nil, for: .default)

			tintColor = .white
			barTintColor = newColor
			titleTextAttributes = [
				NSForegroundColorAttributeName: UIColor.white,
			]
		} else {
			tintColor = nil
			barTintColor = nil
			tintColor = nil
		}
	}
}

extension UIToolbar {
	func setTheme(with color: UIColor?) { jack.debug("▣ \(type(of: self))")
		if let newColor = color {
			tintColor = .white
			barTintColor = newColor
		} else {
			tintColor = nil
			barTintColor = nil
		}
	}
}

extension UITabBar {
	func setTheme(with color: UIColor?) { jack.debug("▣ \(type(of: self))")
		if let newColor = color {
			tintColor = .white
			barTintColor = newColor
			subviews.forEach {
				$0.tintColor = .white
			}
		} else {
			tintColor = nil
			barTintColor = nil
			subviews.forEach {
				$0.tintColor = nil
			}
		}
	}
}

extension UISwitch {
	open override func tintColorDidChange() {
		setTheme(with: tintColor)
	}

	func setTheme(with color: UIColor?) { jack.debug("▣ \(type(of: self))")
		onTintColor = tintColor
	}
}

class TintedLabel: UILabel {
	override func tintColorDidChange() {
		textColor = tintColor
	}
}
