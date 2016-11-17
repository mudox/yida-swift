//
//  PhotosCollectionViewCell.swift
//  YiDaIOSSwiftPractices
//
//  Created by Mudox on 28/10/2016.
//  Copyright © 2016 Mudox. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "Photos Collection View Cell"
  
  @IBOutlet weak var theImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    theImageView.layer.cornerRadius = 4
    theImageView.layer.masksToBounds = true
  }
}
