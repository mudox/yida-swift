//
//  ClassRosterTableViewController.swift
//  Main
//
//  Created by Mudox on 15/11/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

class ClassRosterTableViewController: UITableViewController {

  // MARK: Outlets
  @IBOutlet weak var headerClassIDLabel: UILabel!

  @IBOutlet var toolbarItemsView: UIView!
  @IBOutlet weak var toolbarContainerItem: UIBarButtonItem!
  @IBOutlet var sortByControl: UISegmentedControl!
  @IBOutlet var editTypeControl: UISegmentedControl!
  @IBOutlet weak var groupByClassButton: UIButton!

  @IBOutlet weak var editButton: UIBarButtonItem!

  var roster: ClassRoster!

  let disposeBag = DisposeBag()

  deinit {
    jack.debug("Bye!")
  }

}

// MARK: - as UIViewController
extension ClassRosterTableViewController {

  /**
   only called once by viewDidLoad()
   */
  func setupLogic() {
    editButton.rx.tap.subscribe(onNext: {
      [unowned self] in
      if self.editButton.title == "编辑" {
        self.setEditing(true, animated: true)
        self.editButton.title = "完成"
        self.editTypeControl.isEnabled = true
      } else {
        self.setEditing(false, animated: true)
        self.editButton.title = "编辑"
        self.editTypeControl.isEnabled = false
      }
    }).addDisposableTo(disposeBag)

    groupByClassButton.rx.tap.subscribe(onNext: {
      [unowned self] in
      if self.groupByClassButton.title(for: .normal) == "分班" {
        self.groupByClassButton.setTitle("不分班", for: .normal)
        self.headerClassIDLabel.isHidden = true
      } else {
        self.groupByClassButton.setTitle("分班", for: .normal)
        self.headerClassIDLabel.isHidden = false
      }
      self.tableView.reloadData()
    }).addDisposableTo(disposeBag)

    sortByControl.rx.value.subscribe(onNext: {
      [unowned self](index: Int) in
      switch index {
      case 0:
        self.roster.sortingCriteria = .name
      case 1:
        self.roster.sortingCriteria = .age
      case 2:
        self.roster.sortingCriteria = .id
      default:
        fatalError()
      }
      self.tableView.reloadData()
    }).addDisposableTo(disposeBag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    installDismissButtonOnNavigationBar()

    roster = ClassRoster.fakeRoster

    tableView.register(ClassRosterTableHeaderView.self, forHeaderFooterViewReuseIdentifier: ClassRosterTableHeaderView.identifier)

    setupLogic()
  }

  /**
   only called by viewWillAppear()
   */
  func showToolbar() {
    // must first unhide tool bar
    navigationController?.setToolbarHidden(false, animated: false)

    toolbarItemsView.bounds.size.width = view.bounds.width - 20
    toolbarContainerItem.customView = toolbarItemsView

    let titleAttributes = [
      NSFontAttributeName: UIFont.systemFont(ofSize: 13),
      NSForegroundColorAttributeName: theWindow.tintColor
    ]
    navigationController?.toolbar.setTheme(with: nil)
    navigationController?.toolbar.items?.forEach {
      $0.setTitleTextAttributes(titleAttributes, for: .normal)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    showToolbar()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    navigationController?.setToolbarHidden(true, animated: false)
  }
}

// MARK: - as UITableViewDataSource
extension ClassRosterTableViewController {

  var isGroupedByClass: Bool {
    return groupByClassButton.title(for: .normal) == "不分班"
  }

  func student(forIndexPath indexPath: IndexPath) -> Student {
    if isGroupedByClass {
      return students(forClassIDAtSection: indexPath.section)[indexPath.row]
    } else {
      assert(indexPath.section == 0)
      return roster.ungrouped[indexPath.row]
    }
  }

  func students(forClassIDAtSection section: Int) -> [Student] {
    guard isGroupedByClass else {
      fatalError()
    }

    let classID = roster.allClassIDs[section]
    return roster.grouped[classID]!
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    if isGroupedByClass {
      return roster.allClassIDs.count
    } else {
      return 1
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isGroupedByClass {
      return students(forClassIDAtSection: section).count
    } else {
      return roster.ungrouped.count
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StudentTableViewCell.identifier, for: indexPath) as! StudentTableViewCell

    cell.set(withInfo: student(forIndexPath: indexPath))
    cell.classIDLabel.isHidden = isGroupedByClass

    return cell
  }

  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    if isGroupedByClass {
      return roster.allClassIDs
    } else {
      return nil
    }
  }

  override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return index
  }
}

// MARK: - as UITableViewDelegate
extension ClassRosterTableViewController {

  // MARK: Header view
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    if isGroupedByClass {
      let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ClassRosterTableHeaderView.identifier) as! ClassRosterTableHeaderView
      headerView.set(withClassInfo: students(forClassIDAtSection: section))
      return headerView
    } else {
      return nil
    }
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if isGroupedByClass {
      return ClassRosterTableHeaderView.viewHeight
    } else {
      return 0
    }
  }

  override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    if isGroupedByClass {
      return ClassRosterTableHeaderView.viewHeight
    } else {
      return 0
    }
  }

  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */

  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */

  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

   }
   */

  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
