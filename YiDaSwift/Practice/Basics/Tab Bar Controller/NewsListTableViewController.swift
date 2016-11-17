//// NewsListTableViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 22/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewsListTableViewController: UITableViewController {

	// enable RxSwift
	let newsList = Observable.just(DataSource.newsList)
	let disposeBag = DisposeBag()

	var urlToBrowse: URL?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()

		installDismissButtonOnNavigationBar()

		tableView.dataSource = nil
		tableView.delegate = nil

		bindToDataSource()
		clickCellToShowBrowser()
	}

	private func bindToDataSource() {
		newsList.bindTo(tableView.rx.items(
			cellIdentifier: NewsListTableViewCell.identifier,
			cellType: NewsListTableViewCell.self)
		) { row, newsItem, cell in
			cell.configure(with: newsItem)
		}
			.addDisposableTo(disposeBag)
	}

	private func clickCellToShowBrowser() {
		tableView.rx
			.modelSelected(NewsItem.self)
			.subscribe(onNext: {
				newsItem in

				let vc = self.storyboard!.instantiateViewController(withIdentifier: WebBrowserViewController.storyboardReferenceID) as! WebBrowserViewController
				vc.homeURL = newsItem.url
				self.navigationController!.pushViewController(vc, animated: true)

		}).addDisposableTo(disposeBag)
	}
}

// MARK: - as UITableViewDataSource
//extension NewsListTableViewController {
//  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return newsList.count
//  }
//
//  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "News List Cell", for: indexPath) as! NewsListTableViewCell
//    cell.configure(with: newsList[indexPath.row])
//    return cell
//  }
//}

// MARK: - as UITableViewDelegate
//extension NewsListTableViewController {
//  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//
//    let newsItem = newsList[indexPath.row]
//    urlToBrowse = newsItem.url
//    performSegue(withIdentifier: "Browse News Content", sender: self)
//  }
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    guard segue.identifier == "Browse News Content" else {
//      fatalError("unexpected segue identifier '\(segue.identifier)'")
//    }
//
//    let browserVC = segue.destination as! BrowserViewController
//    browserVC.homeURL = urlToBrowse
//  }
//}
