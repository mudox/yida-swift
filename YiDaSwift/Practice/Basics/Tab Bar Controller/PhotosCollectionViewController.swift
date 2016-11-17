//
//  PhotosCollectionViewController.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 25/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController {

	// MARK: Datasource
	let imageCount = 18

	lazy var regularImages: [UIImage] = {
		var images = [UIImage]()
		for _ in 0..<self.imageCount {
			images.append(
				DataSource.placeHolderImage.anImage(ofSize: CGSize(width: 120, height: 180))
			)
		}

		return images
	}()

	lazy var randomlySizedImages: [UIImage] = {
		let baseWidth: CGFloat = 100
		let baseHeight: CGFloat = 80
		var images = [UIImage]()

		for _ in 0..<self.imageCount {
			let maxDelta: UInt32 = 20
			let size = CGSize(
				width: CGFloat(Int(arc4random_uniform(maxDelta * 2)) - Int(maxDelta)) + baseWidth,
				height: CGFloat(Int(arc4random_uniform(maxDelta * 2)) - Int(maxDelta)) + baseHeight
			)

			images.append(
				DataSource.placeHolderImage.anImage(ofSize: size)
			)
		}

		return images
	}()

	lazy var baseWidth: CGFloat = {
		let screenWidth = UIScreen.main.bounds.size.width
		let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
		let margin = layout.sectionInset.left
		let spacing = layout.minimumLineSpacing
		return (screenWidth - margin * 2 - spacing * 2) / 3
	}()

	lazy var baseHeight: CGFloat = { return self.baseWidth * 1.4 }()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Do any additional setup after loading the view.

		installDismissButtonOnNavigationBar()

		(collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: baseWidth, height: baseHeight)
	}

	// override func didReceiveMemoryWarning() {
	// super.didReceiveMemoryWarning()
	// // Dispose of any resources that can be recreated.
	// }

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using [segue destinationViewController].
	 // Pass the selected object to the new view controller.
	 }
	 */

	// MARK: UICollectionViewDataSource

	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch section {
		case 0:
			return regularImages.count
		case 1:
			return randomlySizedImages.count
		default:
			fatalError()
		}
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifier, for: indexPath) as! PhotosCollectionViewCell
		switch indexPath.section {
		case 0:
			cell.theImageView.image = regularImages[indexPath.item]
		case 1:
			cell.theImageView.image = randomlySizedImages[indexPath.item]
		default:
			fatalError()
		}

		return cell
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		if kind != UICollectionElementKindSectionHeader {
			return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
		}

		let headerView = collectionView.dequeueReusableSupplementaryView(
			ofKind: UICollectionElementKindSectionHeader,
			withReuseIdentifier: PhotosCollectionSectionHeaderView.identifer,
			for: indexPath
		) as! PhotosCollectionSectionHeaderView

		headerView.headerLabel.text = (indexPath.section == 0)
			? "尺寸一致的图片"
			: "尺寸随机的图片"

		return headerView
	}
}

// MARK: as UICollectionViewDelegate
extension PhotosCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let text = "\(indexPath.section) : \(indexPath.item)"
		let image = PlaceholderImageSource.anImage(ofSize: view.bounds.size, text: text)

		let vc = storyboard!.instantiateViewController(withIdentifier: ImageBrowserViewController.identifier) as! ImageBrowserViewController
		vc.image = image

		present(vc, animated: true, completion: nil)
	}
}

// MARK: as UICollectionViewDelegateFlowLayout
extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		switch indexPath.section {
		case 0:
			return CGSize(width: baseWidth, height: baseHeight)
		case 1:
			return randomlySizedImages[indexPath.item].size
		default:
			fatalError()
		}
	}
}
