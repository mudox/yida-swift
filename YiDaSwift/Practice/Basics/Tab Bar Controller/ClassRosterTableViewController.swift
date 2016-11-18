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
  @IBOutlet weak var groupByClassButton: UIButton!

  @IBOutlet weak var editButton: UIButton!

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

      // enter editing mode is the edit button is selected
      self.editButton.isSelected = !self.editButton.isSelected
      self.tableView.reloadData()
    }).addDisposableTo(disposeBag)

    groupByClassButton.rx.tap.subscribe(onNext: {
      [unowned self] in

      // group student by class if the button is selected
      self.groupByClassButton.isSelected = !self.groupByClassButton.isSelected
      self.headerClassIDLabel.isHidden = self.groupByClassButton.isSelected

      self.tableView.reloadData()

    }).addDisposableTo(disposeBag)

    sortByControl.rx.value.subscribe(onNext: {
      [unowned self](index: Int) in
      switch index {
      case 0:
        self.roster.sortByName()
      case 1:
        self.roster.sortByAge()
      case 2:
        self.roster.sortByID()
      default:
        // keep it as is
        break
      }

      self.tableView.reloadData()

    }).addDisposableTo(disposeBag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    installDismissButtonOnNavigationBar()

    // data model
    roster = ClassRoster.fakeRoster

    // table header view
    tableView.tableHeaderView!.backgroundColor = theWindow.tintColor
    let stackView = tableView.tableHeaderView!.subviews[0] as! UIStackView
    for view in stackView.arrangedSubviews {
      let label = view as! UILabel
      label.textColor = .white
    }

    // section index title
    tableView.sectionIndexBackgroundColor = .clear
    tableView.sectionIndexMinimumDisplayRowCount = 10

    // section header view
    tableView.register(ClassRosterTableHeaderView.self, forHeaderFooterViewReuseIdentifier: ClassRosterTableHeaderView.identifier)

    // buttons logic
    setupLogic()

    tableView.setEditing(true, animated: false)
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

// MARK: - as UITableViewDataSource & UITableViewDelegate
extension ClassRosterTableViewController {

  // MARK: Load data

  var isGroupedByClass: Bool {
    return groupByClassButton.isSelected
  }

  func student(forRowAt indexPath: IndexPath) -> Student {
    assert(indexPath.row != 0, "the 1st row is left for 'Add' cell")

    if isGroupedByClass {
      return students(inSection: indexPath.section)[indexPath.row - 1]
    } else {
      assert(indexPath.section == 0)
      return roster.students[indexPath.row - 1]
    }
  }

  func students(inSection section: Int) -> [Student] {
    assert(isGroupedByClass)

    let classID = roster.allClassIDs[section]
    return roster.studentsGroupedByClassID[classID]!
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    if isGroupedByClass {
      return roster.allClassIDs.count
    } else {
      return 1
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // the 1st row (in each section) is left for 'Add' cell
    if isGroupedByClass {
      return students(inSection: section).count + 1
    } else {
      return roster.students.count + 1
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let addStudentCellID = "Add Student Cell"

    // the 1st row is left for Add cell wether the items is grouped or not
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: addStudentCellID, for: indexPath)
      cell.textLabel!.textColor = theWindow.tintColor
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: StudentTableViewCell.identifier, for: indexPath) as! StudentTableViewCell
      cell.set(withInfo: student(forRowAt: indexPath))
      cell.classIDLabel.isHidden = isGroupedByClass
      return cell
    }
  }

  // MARK: Section index

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

  // MARK: Header view

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    if isGroupedByClass {
      let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ClassRosterTableHeaderView.identifier) as! ClassRosterTableHeaderView
      headerView.set(withClassInfo: students(inSection: section))
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

  // MARK: Move item
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    if indexPath.row == 0 {
      return false
    } else {
      return editButton.isSelected
    }
  }

  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    assert(sourceIndexPath.section == destinationIndexPath.section)
    if isGroupedByClass {
      let classID = roster.allClassIDs[sourceIndexPath.section]
      roster.moveStudentInGroupedView(ofClass: classID, at: sourceIndexPath.row, to: destinationIndexPath.row)
    } else {
      roster.moveStudent(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
  }

  override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
    if isGroupedByClass {
      if proposedDestinationIndexPath.section > sourceIndexPath.section {
        let sourceSection = sourceIndexPath.section
        let upperboundRowInSourceSection = students(inSection: sourceSection).count
        return IndexPath(row: upperboundRowInSourceSection, section: sourceIndexPath.section)
      } else if proposedDestinationIndexPath.section < sourceIndexPath.section {
        return IndexPath(row: 0, section: sourceIndexPath.section)
      } else {
        return proposedDestinationIndexPath
      }
    } else {
      return proposedDestinationIndexPath
    }
  }

  // MARK: Selction

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  // MARK: Deleting/Inserting item
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if indexPath.row == 0 {
      // the first row (wether in grouped section or not) is always left for Add cell
      return .insert
    } else {
      // for all other student cells
      if editButton.isSelected {
        return .delete
      } else {
        return .none
      }
    }
  }

  override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    if indexPath.row == 0 {
      return true
    } else {
      return editButton.isSelected
    }
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .insert:
      assert(indexPath.row == 0)

      if isGroupedByClass {
        let classID = roster.allClassIDs[indexPath.section]
        roster.addAFakeStudent(withClassID: classID)
      } else {
        roster.addAFakeStudent()
      }
      var insertIndexPath = indexPath
      insertIndexPath.row = 1
      tableView.insertRows(at: [insertIndexPath], with: .automatic)

    case .delete:
      assert(indexPath.row != 0)

      roster.removeStudent(student(forRowAt: indexPath))
      tableView.deleteRows(at: [indexPath], with: .automatic)

    default:
      break
    }
  }
}
