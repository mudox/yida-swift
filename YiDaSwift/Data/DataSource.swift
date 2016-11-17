//
//  DataSource.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 22/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation

/**
 *  A namespace struct to provide prepared data sources for practice
 */
struct DataSource {
  /// A list of news items about Apple.
  static let newsList = loadNewsUsingGloss()

  /// Generate random names, phone numbers etc.
  static let random = RandomDataSource.self

  /// Generate in-memory place holder image for UI Design uses.
  static let placeHolderImage = PlaceholderImageSource.self
}
