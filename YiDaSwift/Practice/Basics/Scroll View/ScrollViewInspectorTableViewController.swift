//
//  ScrollViewInspectorTableViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 30/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import pop

fileprivate let jack: Jack.Type = {
	Jack.setLevelOfThisFile(.verbose)
	return Jack.self
}()

class ScrollViewInspectorTableViewController: UITableViewController {

	var imageView: UIImageView!
	@IBOutlet weak var scrollView: CenteredZoomOutScrollView!

	// contentOffset labels
	@IBOutlet weak var contentOffsetXlabel: UILabel!
	@IBOutlet weak var contentOffsetYLabel: UILabel!

	// contentSize labels
	@IBOutlet weak var contentSizeWidthLabel: UILabel!
	@IBOutlet weak var contentSizeHeightLabel: UILabel!

	// bounds labels
	@IBOutlet weak var boundsXLabel: UILabel!
	@IBOutlet weak var boundsYLabel: UILabel!
	@IBOutlet weak var boundsWidthLabel: UILabel!
	@IBOutlet weak var boundsHeightLabel: UILabel!

	// content view frame lables
	@IBOutlet weak var frameXLabel: UILabel!
	@IBOutlet weak var frameYLabel: UILabel!
	@IBOutlet weak var frameWidthLabel: UILabel!
	@IBOutlet weak var frameHeightLabel: UILabel!

	// content view transform
	@IBOutlet weak var transformALabel: UILabel!
	@IBOutlet weak var transformBLabel: UILabel!
	@IBOutlet weak var transformCLabel: UILabel!
	@IBOutlet weak var transformDLabel: UILabel!

	// indicators
	@IBOutlet weak var trackingLabel: UILabel!
	@IBOutlet weak var draggingLabel: UILabel!
	@IBOutlet weak var deceleratingLabel: UILabel!
	@IBOutlet weak var zoomingLabel: UILabel!
	@IBOutlet weak var zoomBouncingLabel: UILabel!

	// simulator area
	@IBOutlet weak var fakeScrollView: UIView!
	@IBOutlet weak var fakeScrollViewBounds: UIView!
	@IBOutlet weak var fakeContentView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let image = PlaceholderImageSource.anImage(
			ofSize: CGSize(width: 414, height: 736 / 3),
			text: "缩 放 我",
			maxFontPoint: 26
		)

		imageView = UIImageView(image: image)
		scrollView.internalStateListener = self
		scrollView.contentView = imageView

		fakeScrollView.backgroundColor = .clear
		fakeScrollView.layer.borderColor = UIColor.lightGray.cgColor
		fakeScrollView.layer.borderWidth = 1

		fakeScrollViewBounds.backgroundColor = .clear
		fakeScrollViewBounds.layer.borderColor = UIColor.orange.cgColor
		fakeScrollViewBounds.layer.borderWidth = 1

		fakeContentView.image = image
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationController?.disablePanInAnyWhereToPop()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.enablePanInAnywhereToPop()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		glowBoxes.removeAll()
	}
}

extension ScrollViewInspectorTableViewController: InternalStateListener {

	func scrollView(
		_ scrollView: CenteredZoomOutScrollView,
		internalStateDidChange newState: CenteredZoomOutScrollView.InternalState
	) {
		// contentOffset
		contentOffsetXlabel.pulseTextUpdate(with: newState.contentOffset.x.shortDescription)
		contentOffsetYLabel.pulseTextUpdate(with: newState.contentOffset.y.shortDescription)

		// contentSize
		contentSizeWidthLabel.pulseTextUpdate(with: newState.contentSize.width.shortDescription)
		contentSizeHeightLabel.pulseTextUpdate(with: newState.contentSize.height.shortDescription)

		// bounds
		boundsXLabel.pulseTextUpdate(with: newState.bounds.origin.x.shortDescription)
		boundsYLabel.pulseTextUpdate(with: newState.bounds.origin.y.shortDescription)
		boundsWidthLabel.pulseTextUpdate(with: newState.bounds.width.shortDescription)
		boundsHeightLabel.pulseTextUpdate(with: newState.bounds.height.shortDescription)

		// frame
		frameXLabel.pulseTextUpdate(with: newState.contentViewFrame?.origin.x.shortDescription)
		frameYLabel.pulseTextUpdate(with: newState.contentViewFrame?.origin.y.shortDescription)
		frameWidthLabel.pulseTextUpdate(with: newState.contentViewFrame?.size.width.shortDescription)
		frameHeightLabel.pulseTextUpdate(with: newState.contentViewFrame?.size.height.shortDescription)

		// transform
		transformALabel.pulseTextUpdate(with: newState.contentViewTransform?.a.shortDescription)
		transformBLabel.pulseTextUpdate(with: newState.contentViewTransform?.b.shortDescription)
		transformCLabel.pulseTextUpdate(with: newState.contentViewTransform?.c.shortDescription)
		transformDLabel.pulseTextUpdate(with: newState.contentViewTransform?.d.shortDescription)

		// indicators
		if newState.isTracking { trackingLabel.pulse(with: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)) }
		if newState.isDragging { draggingLabel.pulse(with: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)) }
		if newState.isDecelerating { deceleratingLabel.pulse(with: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)) }

		if newState.isZooming { zoomingLabel.pulse(with: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)) }
		if newState.isZoomBouncing { zoomBouncingLabel.pulse(with: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)) }

		syncSimulatorCell(newState: newState)
	}

	func syncSimulatorCell(newState: CenteredZoomOutScrollView.InternalState) {
		let newOrigin = CGPoint(x: newState.bounds.origin.x / 2.4, y: newState.bounds.origin.y / 2.4)
		fakeScrollViewBounds.frame.origin = newOrigin

		let newContentSize = CGSize(
			width: newState.contentSize.width / 2.4,
			height: newState.contentSize.height / 2.4
		)

		if newContentSize.width < fakeScrollView.bounds.width {
			let xOffset = (fakeScrollView.bounds.width - newContentSize.width) * 0.5
			let yOffset = (fakeScrollView.bounds.height - newContentSize.height) * 0.5
			fakeContentView.center.x = newContentSize.width * 0.5 + xOffset
			fakeContentView.center.y = newContentSize.height * 0.5 + yOffset
		} else {
			fakeContentView.frame.origin = .zero
		}

		fakeContentView.frame.size = newContentSize
	}
}

fileprivate var glowBoxes = [UILabel: UIView](minimumCapacity: 20)

extension UILabel {

	func pulseTextUpdate(with newText: String?) {
		guard text != newText else {
			return
		}

		var color = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
		if newText != nil && text != nil &&
		(newText! as NSString).floatValue < (text! as NSString).floatValue {
			color = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		}

		text = (newText != nil) ? newText : "n/a"

		pulse(with: color, heightBy: -1)
	}

	func pulse(with color: UIColor, insetWidthBy dx: CGFloat = -2, heightBy dy: CGFloat = -1) {
		let box = getGlowBox()

		textColor = .white

		box.backgroundColor = color
		box.frame = frame.insetBy(dx: dx, dy: dy)
		UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseIn], animations: {
			box.backgroundColor = .clear
			}, completion: { finished in
			if finished {
				self.textColor = .black
			}
		})
	}

	func getGlowBox() -> UIView {
		let box: UIView
		if let view = glowBoxes[self] {
			box = view
		} else {
			box = UIView(frame: frame)
			box.layer.cornerRadius = 2
			box.layer.masksToBounds = true

			glowBoxes[self] = box
			superview?.insertSubview(box, belowSubview: self)
		}
		return box
	}
}
