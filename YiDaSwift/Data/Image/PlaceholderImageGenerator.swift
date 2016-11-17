//
//  PlaceholderImageGenerator.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 30/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

fileprivate let jack = Jack.with(levelOfThisFile: .debug)

class PlaceholderImageGenerator {

	// MARK: Settable properties

	/// The lines(s) to drawing in the center of the image if fit, if is nil, this drawer try to draw a size string instead
	var text: String?
	var imageSize: CGSize
	var backgroundColor = UIColor.orange
	var foregroundColor = UIColor.white

	// specify CGFloat.infinity to lift font size restriction
	var maxFontPoint: CGFloat = 16 // magic 20
	var minFontPoint: CGFloat = 10 // magic 10

	// MARK: Properties for internal computation
	private let infiniteSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)

	private var margin: CGFloat {
		return max(8, min(imageSize.width, imageSize.height) / 10)
	}

	private var textClippingFrame: CGRect {
		let clippingWidth = imageSize.width - 2 * margin
		let clippingHeight = imageSize.height - 2 * margin
		return CGRect(x: margin, y: margin, width: clippingWidth, height: clippingHeight)
	}

	private var fontPoint: CGFloat = 10

	private lazy var textAttributes: [String: Any] = {
		let textStyle = NSMutableParagraphStyle()
		textStyle.alignment = .center

		return [
			NSFontAttributeName: UIFont.systemFont(ofSize: self.fontPoint),
			NSForegroundColorAttributeName: self.foregroundColor,
			NSParagraphStyleAttributeName: textStyle,
		]
	}()

	init(imageSize: CGSize) {
		self.imageSize = imageSize
	}

	// MARK: Draw text

	/**
   Layout text in the given frame.
   If will adjust the self.textAttributes property with appropriate font size on non-nil return.
   
   - parameter text: Single or multiline string to layout in the imageSize area.
   
   - returns: text's Drawing frame if the text can be contained in the imageSize area, nil if not.
   */
	func layout(text: NSString) -> CGRect? {

		// make sure there is enough space, at least for the mnimum font size.
		textAttributes[NSFontAttributeName] = UIFont.systemFont(ofSize: minFontPoint)
		var textSize = text.boundingRect(
			with: infiniteSize,
			options: .usesLineFragmentOrigin,
			attributes: textAttributes,
			context: nil
		).size

		guard textSize.width <= textClippingFrame.width &&
		textSize.height <= textClippingFrame.height else {
			return nil
		}

		// start from the maximum possible font size
		var countOfLines = 0
		text.enumerateLines { (_, _) in
			countOfLines += 1
		}

		var fontPoint = min(
			textClippingFrame.height / CGFloat(countOfLines),
			maxFontPoint
		)

		guard fontPoint >= minFontPoint else {
			return nil
		}

		textAttributes[NSFontAttributeName] = UIFont.systemFont(ofSize: fontPoint)
		textSize = text.boundingRect(
			with: infiniteSize,
			options: .usesLineFragmentOrigin,
			attributes: textAttributes,
			context: nil
		).size

		if textSize.width <= textClippingFrame.width &&
		textSize.height <= textClippingFrame.height {
			let x = margin
			let y = (imageSize.height - textSize.height) / 2
			let width = textClippingFrame.width
			let height = textSize.height
			return CGRect(x: x, y: y, width: width, height: height)
		}

		fontPoint = fontPoint * min(
			textClippingFrame.width / textSize.width,
			textClippingFrame.height / textSize.height
		)

		var infiniteLoopCount = 0
		while true {
			infiniteLoopCount += 1
			guard infiniteLoopCount < 200 else { // magic 200
				jack.error("loop count limit reached")
				return nil
			}

			textAttributes[NSFontAttributeName] = UIFont.systemFont(ofSize: fontPoint)
			textSize = text.boundingRect(
				with: infiniteSize,
				options: .usesLineFragmentOrigin,
				attributes: textAttributes,
				context: nil
			).size

			if textSize.width <= textClippingFrame.width &&
			textSize.height <= textClippingFrame.height {
				break
			} else {
				fontPoint -= 1
				if fontPoint < minFontPoint {
					return nil
				}
			}
		}

		let x: CGFloat = margin
		let y: CGFloat = (imageSize.height - textSize.height) / 2
		let width = textClippingFrame.width
		let height = textSize.height
		return CGRect(x: x, y: y, width: width, height: height)
	}

	func drawText() {
		// draw text property if available
		if let textToDraw = text as NSString? {
			if let textFrame = layout(text: textToDraw) {
				textToDraw.draw(in: textFrame, withAttributes: textAttributes)
			}
			return
		}

		// fall back to try drawing size string
		let sizeText: NSString
		if imageSize.width / imageSize.height > 4 / 3 { // magic 4 / 3
			sizeText = "\(imageSize.width)x\(imageSize.height)" as NSString
		} else {
			sizeText = "\(imageSize.width)\nx\n\(imageSize.height)" as NSString
		}
		if let textFrame = layout(text: sizeText) {
			sizeText.draw(in: textFrame, withAttributes: textAttributes)
		} else {
			jack.warn("layout failed")
		}
	}

	// MARK: Draw background
	func drawBackground() {
		// fill background
		let framePath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
		backgroundColor.setFill()
		framePath.fill()

		// 4 corners
		let lineLength = min(8, min(imageSize.width, imageSize.height) / 10)

		foregroundColor.setStroke()

		let cornersPath = UIBezierPath()
		cornersPath.lineWidth = 1
		var basePoint: CGPoint
		let baseMargin = margin / 2

		// top left corner
		basePoint = CGPoint(x: baseMargin, y: baseMargin)
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x, y: basePoint.y + lineLength))
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x + lineLength, y: basePoint.y))

		// top right
		basePoint = CGPoint(x: imageSize.width - baseMargin, y: baseMargin)
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x, y: basePoint.y + lineLength))
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x - lineLength, y: basePoint.y))

		// bottom left
		basePoint = CGPoint(x: baseMargin, y: imageSize.height - baseMargin)
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x, y: basePoint.y - lineLength))
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x + lineLength, y: basePoint.y))

		// bottom right
		basePoint = CGPoint(x: imageSize.width - baseMargin, y: imageSize.height - baseMargin)
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x, y: basePoint.y - lineLength))
		cornersPath.move(to: basePoint)
		cornersPath.addLine(to: CGPoint(x: basePoint.x - lineLength, y: basePoint.y))

		cornersPath.stroke()
	}

	func drawImage() -> UIImage {
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 0)
		let context = UIGraphicsGetCurrentContext()!

		drawBackground()

		context.saveGState()
		context.clip(to: textClippingFrame)
		drawText()

		let image = UIGraphicsGetImageFromCurrentImageContext()!
		context.restoreGState()

		UIGraphicsEndImageContext()
		return image
	}
}
