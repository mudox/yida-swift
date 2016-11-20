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
import SnapKit

fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

class ClassRosterTableViewController: UITableViewController {

  // MARK: Outlets
  @IBOutlet var searchField: UITextField!
  @IBOutlet var searchItem: UIBarButtonItem!

  @IBOutlet weak var headerStackView: UIStackView!
  @IBOutlet weak var headerNameLabel: UILabel!
  @IBOutlet var headerClassIDLabel: UILabel!

  // input accessory view
  @IBOutlet var inputAccessoryBar: UIView!
  @IBOutlet weak var inputSortByControl: UISegmentedControl!
  @IBOutlet weak var inputGroupByClassButton: UIButton!
  @IBOutlet weak var inputEditButton: UIButton!

  // tool bar
  @IBOutlet var toolbarItemsView: UIView!
  @IBOutlet var toolbarContainerItem: UIBarButtonItem!
  @IBOutlet var sortByControl: UISegmentedControl!
  @IBOutlet weak var groupByClassButton: UIButton!
  @IBOutlet weak var editButton: UIButton!

  lazy var cancelSearchItem: UIBarButtonItem = {
    let item = UIBarButtonItem()
    item.title = "取消"
    item.style = .done
    item.setTitlePositionAdjustment(UIOffset(horizontal: 6, vertical: 0), for: .default)
    return item
  }()

  var roster: ClassRoster!

  let disposeBag = DisposeBag()

  deinit {
    jack.debug("Bye!")
  }

}

// MARK: - as UIViewController
extension ClassRosterTableViewController {

  func editModeChanged(isEditing: Bool) {
    // enter editing mode is the edit button is selected
    editButton.isSelected = isEditing
    inputEditButton.isSelected = isEditing

    tableView.setEditing(isEditing, animated: true)
  }

  func groupModeChanged(isGrouping: Bool) {
    // group student by class if the button is selected
    groupByClassButton.isSelected = isGrouping
    inputGroupByClassButton.isSelected = isGrouping

    if isGrouping {
      headerStackView.removeArrangedSubview(headerClassIDLabel)
      headerClassIDLabel.removeFromSuperview()
    } else {
      headerStackView.addArrangedSubview(headerClassIDLabel)
      headerClassIDLabel.snp.makeConstraints { make in
        make.width.equalTo(headerNameLabel)
      }
    }

    tableView.reloadData()
  }

  func sortByCriteriaChanged(index: Int) {
    sortByControl.selectedSegmentIndex = index
    inputSortByControl.selectedSegmentIndex = index

    switch index {
    case 0:
      roster.sortByName()
    case 1:
      roster.sortByAge()
    case 2:
      roster.sortByID()
    default:
      // keep it as is
      break
    }

    tableView.reloadData()
  }

  /**
   only called once by viewDidLoad()
   */
  func setupLogic() {

    searchItem.rx.tap.subscribe(onNext: {
      [unowned self] in

      self.navigationItem.setRightBarButton(self.cancelSearchItem, animated: true)

      self.inputAccessoryBar.tintColor = theWindow.tintColor
      self.navigationItem.titleView = self.searchField
      self.searchField.becomeFirstResponder()

      self.roster.isSearchModeEnabled = true
    }).addDisposableTo(disposeBag)

    cancelSearchItem.rx.tap.subscribe(onNext: {
      [unowned self] in

      self.navigationItem.setRightBarButton(self.searchItem, animated: true)

      // tear down search field, restore tool items
      self.searchField.resignFirstResponder()
      self.searchField.text = ""
      self.navigationItem.titleView = nil

      self.roster.searchString = ""
      self.roster.isSearchModeEnabled = false

      self.tableView.reloadData()
    }).addDisposableTo(disposeBag)

    searchField.rx.text.orEmpty.throttle(0.3, scheduler: MainScheduler.instance)
      .subscribe(onNext: {
        [unowned self](text: String) in
        self.roster.searchString = text
        self.tableView.reloadData()
    }).addDisposableTo(disposeBag)

    // the 2 edit buttons
    editButton.rx.tap.map { [unowned self]() -> Bool in
      return !self.editButton.isSelected
    }
      .subscribe(onNext: editModeChanged)
      .addDisposableTo(disposeBag)

    inputEditButton.rx.tap.map { [unowned self]() -> Bool in
      return !self.inputEditButton.isSelected
    }
      .subscribe(onNext: editModeChanged)
      .addDisposableTo(disposeBag)

    // the 2 group by class buttons
    // initial show/hide of header class id label
    groupModeChanged(isGrouping: true)
    groupByClassButton.rx.tap.map { [unowned self]() -> Bool in
      return !self.groupByClassButton.isSelected
    }
      .subscribe(onNext: groupModeChanged)
      .addDisposableTo(disposeBag)

    inputGroupByClassButton.rx.tap.map { [unowned self]() -> Bool in
      return !self.inputGroupByClassButton.isSelected
    }
      .subscribe(onNext: groupModeChanged)
      .addDisposableTo(disposeBag)

    // the 2 sort by control
    sortByControl.rx.value
      .subscribe(onNext: sortByCriteriaChanged)
      .addDisposableTo(disposeBag)

    inputSortByControl.rx.value
      .subscribe(onNext: sortByCriteriaChanged)
      .addDisposableTo(disposeBag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    installDismissButtonOnNavigationBar()

    // data model
    roster = ClassRoster.fakeRoster

    searchField.inputAccessoryView = inputAccessoryBar

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

  var isSearching: Bool {
    return navigationItem.titleView == searchField
  }

  func student(forRowAt indexPath: IndexPath) -> Student {
    assert(indexPath.row != 0, "the 1st row is left for 'Add' cell")

    if isGroupedByClass {
      return students(inSection: indexPath.section)[indexPath.row - 1]
    } else {
      assert(indexPath.section == 0)
      return roster.ungroupedView[indexPath.row - 1]
    }
  }

  func students(inSection section: Int) -> [Student] {
    assert(isGroupedByClass)

    let classID = roster.allClassIDs[section]
    return roster.groupedView[classID]!
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
      return roster.ungroupedView.count + 1
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let addStudentCellID = "Add Student Cell"

    // the 1st row is left for Add cell wether the items is grouped or not
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: addStudentCellID, for: indexPath)
      let label = cell.contentView.viewWithTag(100)!
      label.isHidden = isSearching
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: StudentTableViewCell.identifier, for: indexPath) as! StudentTableViewCell
      cell.set(withInfo: student(forRowAt: indexPath))
      if isGroupedByClass {
        cell.stackView.removeArrangedSubview(cell.classIDLabel)
        cell.classIDLabel.removeFromSuperview()
      } else {
        cell.stackView.addArrangedSubview(cell.classIDLabel)
        cell.classIDLabel.snp.makeConstraints { make in
          make.width.equalTo(cell.nameLabel)
        }
      }
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
      return !roster.isSearchModeEnabled
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

    if indexPath.row == 0 {
      if isGroupedByClass {
        let classID = roster.allClassIDs[indexPath.section]
        roster.addAFakeStudent(withClassID: classID)
      } else {
        roster.addAFakeStudent()
      }
      var insertIndexPath = indexPath
      insertIndexPath.row = 1
      tableView.insertRows(at: [insertIndexPath], with: .automatic)
    }
  }

  // MARK: Deleting/Inserting item
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if indexPath.row == 0 {
      // the first row (wether in grouped section or not) is always left for Add cell
      return .none
    } else {
      return .delete
    }
  }

  override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    if indexPath.row == 0 {
      return false
    } else {
      return true
    }
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      assert(indexPath.row != 0)

      roster.removeStudent(student(forRowAt: indexPath))
      if tableView.numberOfRows(inSection: indexPath.section) == 2 { // include the hiding add cell
        tableView.deleteSections([indexPath.section], with: .automatic)
      } else {
        tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    default:
      break
    }
  }
}
