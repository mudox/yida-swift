// : Playground - noun: a place where people can play

import UIKit

let names = [
  "刘兴义", "习近平", "习仲勋", "田伟红"
]

names.sorted {
  left, right in
  return left.compare(right, options: [], range: nil, locale: LocaleName.chineseChina.locale) == .orderedAscending
}