//
//  BrowserViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 22/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class WebBrowserViewController: UIViewController {
	static let storyboardReferenceID = "Web Browser View Controller"

	var homeURL: URL?

	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var addressTextField: UITextField!

	let addressTextFieldAlpha: CGFloat = 0.7
}

// MARK: - as UIViewController
extension WebBrowserViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		addressTextField.backgroundColor = UIColor(white: 1, alpha: addressTextFieldAlpha)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// set UI
		navigationController!.setToolbarHidden(false, animated: true)
		navigationItem.hidesBackButton = true
		setNeedsStatusBarAppearanceUpdate()

		addressTextField.frame.size.width = navigationController!.navigationBar.bounds.width - 20

		// load page if any
		if let urlToLoad = homeURL {
			let request = URLRequest(url: urlToLoad)
			webView.loadRequest(request)
			addressTextField.text = urlToLoad.host
		} else {
			addressTextField.placeholder = "请输入要加载的地址"
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController!.setToolbarHidden(true, animated: animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
	@IBAction func dismiss(_ sender: UIBarButtonItem) {
		navigationController!.popViewController(animated: true)
	}

	@IBAction func goBackward(_ sender: UIBarButtonItem) {
		if webView.canGoBack {
			webView.goBack()
		}
	}

	@IBAction func goForward(_ sender: UIBarButtonItem) {
		if webView.canGoForward {
			webView.goForward()
		}
	}

	@IBAction func goHome(_ sender: Any) {
		if let urlToLoad = homeURL {
			let request = URLRequest(url: urlToLoad)
			webView.loadRequest(request)
		}
	}
}

// MARK: - as UITextFieldDelegate
extension WebBrowserViewController: UITextFieldDelegate {

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.backgroundColor = .white
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let urlString = textField.text!
		if urlString.isEmpty {
			textField.text = homeURL!.absoluteString
		} else {
			goHome(self)
		}

		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		textField.backgroundColor = UIColor(white: 1, alpha: addressTextFieldAlpha)
	}
}
