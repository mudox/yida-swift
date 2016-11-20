//
//  Graphics.swift
//  YiDaSwift
//
//  Created by Mudox on 19/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

/// Draw a 1x1 image for pure color backgrounding usage
func OnePixelImage(withColor color: UIColor) -> UIImage {
  UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0)
  let context = UIGraphicsGetCurrentContext()!

  let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
  color.setFill()
  context.fill(rect)

  let image = UIGraphicsGetImageFromCurrentImageContext()!
  UIGraphicsEndImageContext()

  return image
}
