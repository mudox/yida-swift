//
//  TabBarContentViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 19/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit


class TabBarContentViewController: UIViewController {

  // MARK: - Index & Colors

  static let colors = [#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
  var themeColor: UIColor {
    return TabBarContentViewController.colors[index]
  }

  var index: Int = 0

  @IBOutlet weak var indexLabel: UILabel!

  func setTheme() {
    // theme color
    navigationController!.navigationBar.setTheme(with: themeColor)
    tabBarController!.tabBar.setTheme(with: themeColor)

    // content view
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    themeColor.getRed(&red, green: &green, blue: &blue, alpha: nil)

    let degree: CGFloat = 0.5
    red += (1.0 - red) * degree
    green += (1.0 - green) * degree
    blue += (1.0 - blue) * degree
    let lightenedColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

    view.backgroundColor = lightenedColor
  }

  // MARK: - as UIViewController

  override var tabBarItem: UITabBarItem! {
    get {
      let item = super.tabBarItem!
      item.title = ""

      let yOffset: CGFloat = 6.0
      item.imageInsets = UIEdgeInsets(top: yOffset, left: 0, bottom: -yOffset, right: 0)
      item.image = UIImage(named: "TabIcon-\(index + 1)")
      item.selectedImage = UIImage(named: "TabIcon-\(index + 1)-Selected")

      return super.tabBarItem
    }

    set {
      super.tabBarItem = newValue
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    installDismissButtonOnNavigationBar()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setTheme()
    
    indexLabel.text = "\(index + 1)"
    navigationItem.title = "内容 #\(index + 1)"
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    view.subviews.forEach {
      $0.alpha = 0
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    view.subviews.forEach {
      $0.alpha = 1
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
