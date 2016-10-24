//
//  BusinessCell.swift
//  Yelp
//
//  Created by Duc Dinh on 10/23/16.
//  Copyright © 2016 Duc Dinh. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var ratingImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var reviewsCountLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!
  
  var business: Business! {
    didSet {
      nameLabel.text = business.name
      addressLabel.text = business.address
      categoriesLabel.text = business.categories
      distanceLabel.text = business.distance
      reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
      thumbImageView.setImageWith(business.imageURL!)
      ratingImageView.setImageWith(business.ratingImageURL!)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    thumbImageView.layer.cornerRadius = 5
    thumbImageView.clipsToBounds = true
    
    nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width // to fix iOS but when some long texts are sometime  truncated not wrap to new line
  }
  
  override func layoutSubviews() { // when changing orientation
    super.layoutSubviews()
    nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width // to fix iOS but when some long texts are sometime  truncated not wrap to new line
  }





  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
