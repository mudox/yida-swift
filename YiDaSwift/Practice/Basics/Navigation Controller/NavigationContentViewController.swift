//
//  NavigationContentViewController.swift
//
//
//  Created by Mudox on 04/10/2016.
//
//

import UIKit

private let thisViewControllerIdentifier = "Navigation Controller Manages Content View Controllers"

class NavigationContentViewController: UIViewController {

  static let colors = [#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
  static var instanceCount: Int = 0

  @IBOutlet weak var indexLabel: UILabel!

  var instanceIndex: Int = {
    NavigationContentViewController.instanceCount += 1
    return NavigationContentViewController.instanceCount - 1
  }()

  deinit {
    NavigationContentViewController.instanceCount -= 1
  }

  func setTheme() {
    let baseColor = NavigationContentViewController.colors[instanceIndex]
    theWindow.tintColor = baseColor

    // content view
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0

    baseColor.getRed(&red, green: &green, blue: &blue, alpha: nil)

    let degree: CGFloat = 0.5
    red += (1.0 - red) * degree
    green += (1.0 - green) * degree
    blue += (1.0 - blue) * degree
    let lightenedColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

    indexLabel.backgroundColor = lightenedColor
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    setTheme()

    navigationItem.title = "第\(navigationController!.viewControllers.count)级子视图控制器"
    navigationItem.backBarButtonItem?.title = ""
    indexLabel.text = "\(instanceIndex + 1)"
  }
  
  @IBAction func jumpButtonTapped(_ sender: AnyObject) {
    let title = "导航控制器"
    let message = "请选择跳转到："

    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

    var action: UIAlertAction

    if NavigationContentViewController.instanceCount < 4 {
      action = UIAlertAction(title: "压入新的视图控制器", style: .default, handler: { (action: UIAlertAction) in
        let newContentViewController = self.storyboard!.instantiateViewController(withIdentifier: thisViewControllerIdentifier)
        self.navigationController!.pushViewController(newContentViewController, animated: true)
      })
      alert.addAction(action)
    }

    action = UIAlertAction(title: "上一级视图控制器", style: .default, handler: { (action: UIAlertAction) in
      let _ = self.navigationController?.popViewController(animated: true)
    })
    alert.addAction(action)

    action = UIAlertAction(title: "第二级视图控制器", style: .default, handler: { (action: UIAlertAction) in
      if let secondLevelViewController = self.navigationController?.viewControllers[1] {
        let _ = self.navigationController?.popToViewController(secondLevelViewController, animated: true)
      } else {
        Jack.debug("2nd level content view controller not exists")
      }
    })
    alert.addAction(action)

    action = UIAlertAction(title: "根视图控制器", style: .default, handler: { (action: UIAlertAction) in
      let _ = self.navigationController?.popToRootViewController(animated: true)
    })
    alert.addAction(action)

    action = UIAlertAction(title: "取消", style: .cancel, handler: nil)
    alert.addAction(action)
    self.present(alert, animated: true, completion: nil)
  }

}
