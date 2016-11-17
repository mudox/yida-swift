//
//  MainEarlGreyTests.swift
//  MainEarlGreyTests
//
//  Created by Mudox on 07/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import EarlGrey
import XCTest

class MainEarlGreyTests: XCTestCase {

	let G = EarlGrey.self

	enum Part: String {
		case basics = "Basics 1st Level Button"
		case advanced = "Advanced 1st Level Button"
		case framework = "Framework 1st Level Button"
	}

	func enter(_ part: Part) {
		var error: NSError?
		G.select(elementWithMatcher: grey_accessibilityID(part.rawValue))
			.perform(grey_tap(), error: &error)
	}

	func pop() {
		let navigationBarBackButtonMatcher = grey_allOfMatchers([
			grey_accessibilityLabel(" "),
			grey_accessibilityTrait(UIAccessibilityTraitButton),
		])!

		G.select(elementWithMatcher: navigationBarBackButtonMatcher)
			.inRoot(grey_kindOfClass(UINavigationBar.self))
			.perform(grey_tap())
	}

	func testBasicsPart() {
		testLoginForm()
		testScrollViewTasks()
	}
}

// MARK: -  Basics part tests
extension MainEarlGreyTests {

	func testLoginForm() {
		enter(.basics)

		G.select(elementWithMatcher: grey_accessibilityID("Login Form Interface"))
			.perform(grey_tap())

		G.select(elementWithMatcher: grey_accessibilityID("student name"))
			.perform(grey_tap())
			.perform(grey_replaceText("王尼玛"))

		G.select(elementWithMatcher:
				grey_allOfMatchers([
					grey_accessibilityLabel("女"),
					grey_accessibilityTrait(UIAccessibilityTraitButton),
			])
		).perform(grey_tap())

		G.select(elementWithMatcher: grey_accessibilityID("number"))
			.perform(grey_typeText("YD-2016-0023"))

		G.select(elementWithMatcher: grey_accessibilityID("password"))
			.perform(grey_typeText("thisisasecret"))

		G.select(elementWithMatcher: grey_accessibilityID("phone"))
			.perform(grey_typeText("18388383923"))

		G.select(elementWithMatcher: grey_accessibilityID("birthday"))
			.perform(grey_tap())

		let interval = -3600 * 24 * TimeInterval(arc4random_uniform(356 * 24))
		G.select(elementWithMatcher: grey_accessibilityID("date input picker"))
			.perform(grey_setDate(Date(timeIntervalSinceNow: interval)))

		G.select(elementWithMatcher: grey_accessibilityID("date input ok button"))
			.perform(grey_tap())

		G.select(elementWithMatcher: grey_accessibilityID("address"))
			.perform(grey_replaceText("深圳市福田区车公庙"))

		G.select(elementWithMatcher: grey_accessibilityID("email"))
			.perform(grey_typeText("wangnima@yd.com"))

		G.select(elementWithMatcher: grey_accessibilityID("register"))
			.perform(grey_tap())

		sleep(4)

		G.select(elementWithMatcher: grey_accessibilityID("message view"))
			.perform(grey_tap())

		G.select(elementWithMatcher: grey_accessibilityID("dismiss button"))
			.perform(grey_tap())
	}

	func testScrollViewTasks() {
		enter(.basics)

		G.select(elementWithMatcher: grey_accessibilityID("Scroll View Tasks"))
			.perform(grey_tap())

		G.select(elementWithMatcher: grey_kindOfClass(UIScrollView.self))
			.perform(grey_swipeFastInDirection(.right))
			.perform(grey_swipeFastInDirection(.left))
			.perform(grey_swipeFastInDirection(.left))
			.perform(grey_swipeFastInDirection(.left))
			.perform(grey_swipeFastInDirection(.right))

		G.select(elementWithMatcher: grey_allOfMatchers([
			grey_accessibilityLabel("#2"),
			grey_accessibilityTrait(UIAccessibilityTraitButton),
			])
		)
			.perform(grey_tap())

		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			self.G.select(elementWithMatcher: grey_kindOfClass(UIScrollView.self))
				.perform(grey_swipeFastInDirection(.right))
				.perform(grey_swipeFastInDirection(.right))
				.perform(grey_swipeFastInDirection(.right))
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 3 + 5) {
			self.G.select(elementWithMatcher: grey_kindOfClass(UIScrollView.self))
				.perform(grey_swipeFastInDirection(.left))
				.perform(grey_swipeFastInDirection(.left))
				.perform(grey_swipeFastInDirection(.left))
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 3 + 5 + 4) {
			self.pop()
		}
	}
}
