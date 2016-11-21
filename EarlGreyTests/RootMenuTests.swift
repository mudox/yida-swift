//
//  RootMenuTests.swift
//  YiDaSwift
//
//  Created by Mudox on 21/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import EarlGrey
import XCTest

extension MainEarlGreyTests {
  func testRootMenuFilterButtons() {
    var error: NSError?

    for part: Part in [.basic, .advanced, .framework] {
      tryEnter(part, isErrorFatal: part != .basic)

      let gtg = G.select(elementWithMatcher: grey_accessibilityID("Good To Go Button"))
      let pinned = G.select(elementWithMatcher: grey_accessibilityID("Pinned Button"))
      let wip = G.select(elementWithMatcher: grey_accessibilityID("Working In Process Button"))
      let planning = G.select(elementWithMatcher: grey_accessibilityID("Planning Button"))
      let all = G.select(elementWithMatcher: grey_accessibilityID("All Button"))

      planning.perform(grey_tap(), error: &error)
      gtg.perform(grey_tap(), error: &error)
      pinned.perform(grey_tap(), error: &error)
      all.perform(grey_tap(), error: &error)

      wip.perform(grey_tap(), error: &error)
      planning.perform(grey_tap(), error: &error)
      wip.perform(grey_tap(), error: &error)
      planning.perform(grey_tap(), error: &error)

    }

  }
}
