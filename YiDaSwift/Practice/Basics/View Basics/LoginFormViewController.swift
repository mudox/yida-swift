
//  LoginFormViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 03/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftValidators
import SwiftMessages
import PySwiftyRegex

fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

class LoginFormViewController: UIViewController {

	deinit {
		jack.debug("Bye!")
	}

	let placeholderText = [
		"必填",
		"必填，格式：YD-2016-3838",
		"必填，不小于6个字符",
		"必填，限中国大陆号码",
		"必填，点击选择出生年月",
		"必填",
		"可选",
	]

	let textFieldTagRange = 99 ... 105

	var textFields: [UITextField] {
		return textFieldTagRange.map {
			self.view.viewWithTag($0) as! UITextField
		}
	}

	let messageViewTagRange = 199 ... 205

	var messageViews: [UILabel] {
		return messageViewTagRange.map {
			self.view.viewWithTag($0) as! UILabel
		}
	}

	func messageView(for textField: UITextField) -> UILabel {
		return view.viewWithTag(textField.tag + 100) as! UILabel
	}

	let placeholderViewTag = 1000
	func placeholderView(for textField: UITextField) -> UILabel {
		return textField.viewWithTag(placeholderViewTag) as! UILabel
	}

	// MARK: - Outlets
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!

	@IBOutlet weak var headerImageView: UIImageView!
	@IBOutlet weak var avatarImageView: UIImageView!

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var genderSegmentedControl: UISegmentedControl!
	@IBOutlet weak var numberTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var phoneTextField: UITextField!
	@IBOutlet weak var birthdayTextField: UITextField!
	@IBOutlet weak var addressTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!

	@IBOutlet weak var registerButton: UIButton!

	// input view for birthday text field
	@IBOutlet var dateInputView: UIView!
	@IBOutlet var dateInputPicker: UIDatePicker!

	@IBOutlet weak var dateInputOKButton: UIButton!

	var activeTextField: UITextField?
	let disposeBag = DisposeBag()
}

// MARK: - as UIViewController
extension LoginFormViewController {

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		initSubviews()
		setupRegisterButtonAction()
		configureFieldValidation()
		observeKeyboardnotifications()
	}

	// MARK: UI Setup

	func initSubviews() {

		// interface from top to bottom

		// back button
		backButton.tintColor = .darkGray
		backButton.rx.tap.subscribe(onNext: { [unowned self] in
			self.dismiss(animated: true, completion: nil)
		}).addDisposableTo(disposeBag)

		// header image view
		headerImageView.layer.cornerRadius = 10
		headerImageView.addSubview(avatarImageView)

		// text fields
		for tag in textFieldTagRange {
			// clear button for each text field
			let clearButton = UIButton(type: .custom)
			clearButton.setImage(#imageLiteral(resourceName: "Clear"), for: .normal)
			clearButton.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
			clearButton.tintColor = .lightGray
			clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)

			clearButton.rx.tap
				.subscribe(onNext: { [weak self] _ in
					self?.activeTextField?.text = ""
			}).addDisposableTo(disposeBag)

			let textField = view.viewWithTag(tag) as! UITextField
			textField.rightView = clearButton
			textField.rightViewMode = .whileEditing
			textField.clearButtonMode = .never

			// placeholder text for each text field
			let label = UILabel()
			label.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightThin)
			label.textColor = .darkGray
			label.text = placeholderText[tag - 99]

			label.tag = placeholderViewTag
			textField.addSubview(label)
			label.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				label.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
				label.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
			])
		}

		// focus on next field if user press return on the field
		textFields.forEach {
			(tf: UITextField) in
			tf.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
				[unowned self] in
				self.focusOnNextField(of: tf)
			}).addDisposableTo(disposeBag)
		}

		birthdayTextField.rx.controlEvent(.editingDidBegin).subscribe(onNext: {
			[unowned self] in
			if self.birthdayTextField.inputView == nil {
				self.setupInputViewForBithdayTextField()
			}
		}).addDisposableTo(disposeBag)

		// hide all message views
		messageViewTagRange.map { self.view.viewWithTag($0)! }.forEach { $0.isHidden = true }

		// registr button
		registerButton.layer.cornerRadius = 3
	}

	func setupInputViewForBithdayTextField() {
		// input view
		birthdayTextField.inputView = dateInputView
		dateInputPicker.accessibilityIdentifier = "date input picker"
		dateInputPicker.maximumDate = Date()

		dateInputPicker.rx.date.subscribe(onNext: {
			[unowned self](newDate: Date) in
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy年-MM月-dd日"
			self.birthdayTextField.text = formatter.string(from: newDate)
		}).addDisposableTo(self.disposeBag)

		dateInputOKButton.rx.tap.subscribe(onNext: {
			[unowned self] in
			self.focusOnNextField(of: self.birthdayTextField)
		}).addDisposableTo(self.disposeBag)
	}
}

// MARK: - as UITextFieldDelegate
extension LoginFormViewController: UITextFieldDelegate {

	func textFieldDidBeginEditing(_ textField: UITextField) {
		activeTextField = textField

		// hide placeholder view
		placeholderView(for: textField).isHidden = true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		activeTextField = nil
	}

	func focusOnNextField(of textField: UITextField) {
		if let nextField = view.viewWithTag(textField.tag + 1) {
			nextField.becomeFirstResponder()
			var rect = scrollView.convert(nextField.bounds, from: nextField)
			rect = rect.insetBy(dx: 0, dy: -20)
			scrollView.scrollRectToVisible(rect, animated: true)
		}
	}
}

// MARK: - Form validation
extension LoginFormViewController {

	func showMessage(_ message: String, for textField: UITextField) {
		let label = messageView(for: textField)
		label.text = message

		label.isHidden = false
//		scrollView.scrollRectToVisible(scrollView.convert(label.bounds, from: label), animated: false)
	}

	func hideMessageView(for textField: UITextField) {
		let label = messageView(for: textField)
		label.isHidden = true
	}

	func enableRegisterButton(_ enabled: Bool = true) {
		registerButton.isEnabled = enabled

		if enabled {
			registerButton.backgroundColor = .orange
		} else {
			registerButton.backgroundColor = .lightGray
		}
	}
}

// MARK: - Using RxSwift
extension LoginFormViewController {

	func configureFieldValidation() {
		var observables = [UITextField: Observable<String?>]()

		let obsv1: Observable<String?> = nameTextField.rx.text.map {
			(newText: String?) -> String? in

			if !Validators.required()(newText) {
				return "请填写学员姓名"
			} else {
				return nil
			}
		}.skip(1)
		observables[nameTextField] = obsv1

		let obsv2: Observable<String?> = numberTextField.rx.text.map {
			(newText: String?) -> String? in

			if !Validators.required()(newText) {
				return "请填写学员编号"
			} else if !Validators.regex("YD-\\d{4}-\\d{4}")(newText) {
				return "请符合如下格式：YD-2016-0026"
			} else {
				return nil
			}
		}.skip(1)
		observables[numberTextField] = obsv2

		let obsv3: Observable<String?> = passwordTextField.rx.text.map {
			(newText: String?) -> String? in

			if !Validators.required()(newText) {
				return "请填写学员密码"
			} else if !Validators.isAlphanumeric()(newText) {
				return "密码只接受数字和字母"
			} else if !Validators.minLength(6)(newText) {
				return "密码长度密码长度不能小于6"
			} else {
				return nil
			}
		}.skip(1)
		observables[passwordTextField] = obsv3

		let obsv4: Observable<String?> = phoneTextField.rx.text.map {
			(newText: String?) -> String? in

			if !Validators.required()(newText) {
				return "请填写学员手机号码（限中国大陆）"
			} else if !Validators.isPhone(.zh_CN)(newText) {
				return "无效的手机号码"
			} else {
				return nil
			}
		}.skip(1)
		observables[phoneTextField] = obsv4

		let obsv5: Observable<String?> = birthdayTextField.rx.text.map {
			(newText: String?) -> String? in

			if !Validators.required()(newText) {
				return "请填写学员出生日期"
			} else if !Validators.isDate("yyyy年-MM月-dd日")(newText) {
				return "无效的日期格式（1990年-3月-12日）"
			} else {
				return nil
			}
		}.skip(1)
		observables[birthdayTextField] = obsv5

		let obsv6: Observable<String?> = addressTextField.rx.text.map {
			(newText: String?) -> String? in

			if !Validators.required()(newText) {
				return "请填写学员联系地址"
			} else {
				return nil
			}
		}.skip(1)
		observables[addressTextField] = obsv6

		let obsv7: Observable<String?> = emailTextField.rx.text.map {
			(newText: String?) -> String? in

			let validator = Validators.isEmpty() || Validators.isEmail()
			if !validator(newText) {
				return "无效的电子邮件地址"
			} else {
				return nil
			}
		}.skip(1)
		observables[emailTextField] = obsv7

		// register button enabled states
		let a: Observable<Bool> = Observable.combineLatest(obsv1, obsv2) {
			return ($0 == nil) && ($1 == nil)
		}
		let b: Observable<Bool> = Observable.combineLatest(obsv3, obsv4) {
			return ($0 == nil) && ($1 == nil)
		}
		let c: Observable<Bool> = Observable.combineLatest(obsv5, obsv6) {
			return ($0 == nil) && ($1 == nil)
		}
		let d: Observable<Bool> = Observable.combineLatest(a, b, c, obsv7) {
			return $0 && $1 && $2 && ($3 == nil)
		}

		d.subscribe(onNext: {
			[unowned self](enabled: Bool) in
			self.registerButton.isEnabled = enabled
			self.registerButton.backgroundColor = enabled ? .orange : .darkGray
		}).addDisposableTo(disposeBag)

		// drive message labels' show/hide & register button's enabled states
		for (field, obsv) in observables {
			obsv.subscribe(onNext: {
				[unowned self](message: String?) in

				if let text = message {
					self.showMessage(text, for: field)
				} else {
					self.hideMessageView(for: field)
				}
			}).addDisposableTo(disposeBag)
		}
	}

	func observeKeyboardnotifications() {
		// adapt to keyboard show/hide
		theNotificationCenter.rx
			.notification(.UIKeyboardWillShow)
			.subscribe(onNext: { [unowned self] notify in
				var keyboardFrame = (notify.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
				keyboardFrame = theWindow.convert(keyboardFrame, from: nil)
				let coveredArea = theWindow.bounds.intersection(keyboardFrame)
				jack.debug("set bottom inset to \(coveredArea.height)")

				self.scrollView.contentInset.bottom = coveredArea.height
				self.scrollView.scrollIndicatorInsets.bottom = coveredArea.height
		}).addDisposableTo(disposeBag)

		// inspect keyboard show/hide changes
		for name: Notification.Name in [
				.UIKeyboardWillShow, .UIKeyboardDidShow,
				.UIKeyboardWillChangeFrame, .UIKeyboardDidChangeFrame,
				.UIKeyboardWillHide, .UIKeyboardDidHide,
		] {
			theNotificationCenter.rx.notification(name).subscribe(onNext: {
				notify in

				let beginFrame = (notify.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
				let endFrame = (notify.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

				let match = re.search("(Will|Did)(Show|ChangeFrame|Hide)", name.rawValue)!
				var willOrDid = match.group(1)!.lowercased()
				let what = match.group(2)!.lowercased()
				if willOrDid == "did" { willOrDid = " " + willOrDid }

				var changeText = ""
				if beginFrame.minY != endFrame.minY {
					changeText += "\ny: \(beginFrame.minY) -> \(endFrame.minY)"
				}
				if beginFrame.height != endFrame.height {
					changeText += "\nheight: \(beginFrame.height) -> \(endFrame.height)"
				}

				let text = "\(willOrDid) \(what)"
				jack.debug(text + changeText, withPrefix: .text("Keyboard"))

			}).addDisposableTo(disposeBag)
		}
	}

	func setupRegisterButtonAction() {
		registerButton.rx.tap.subscribe(onNext: {
			[unowned self] in

			self.activeTextField?.resignFirstResponder()

			let gender = (self.genderSegmentedControl.selectedSegmentIndex == 0) ? "男" : "女"

			// calculate age
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy年-MM月-dd日"
			let birthday = dateFormatter.date(from: self.birthdayTextField.text!)!
			let age = "\(Int(Date().timeIntervalSince(birthday)) / (3600 * 365))"

			let title = "\(self.nameTextField.text!) \(gender)(\(age) 岁) \n"

			var body =
				"\n - 　　编号：\(self.numberTextField.text!) \n"
				+ " - 　　密码：\(self.passwordTextField.text!) \n"
				+ " - 电话号码：\(self.numberTextField.text!) \n"
				+ " - 联系地址：\(self.addressTextField.text!) "

			if self.addressTextField.text! != "" {
				body += "\n - 邮件地址：\(self.emailTextField.text!) "
			}

			body += "\n\n 下滑或点击暗影区域以撤下本消息框"

			let view = MessageView.viewFromNib(layout: .CardView)
			view.accessibilityIdentifier = "message view"

			view.configureTheme(.success)
			view.configureContent(title: title, body: body)

			view.iconImageView?.isHidden = true
			view.button?.isHidden = true
			view.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
			view.titleLabel?.textAlignment = .center
			view.bodyLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)

			var config = SwiftMessages.Config()
			config.presentationStyle = .bottom
			config.dimMode = .gray(interactive: true)
			config.duration = .forever

			SwiftMessages.show(config: config, view: view)

		}).addDisposableTo(disposeBag)
	}
}
