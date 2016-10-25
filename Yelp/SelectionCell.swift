//
//  SelectionCell.swift
//  Yelp
//
//  Created by Duc Dinh on 10/25/16.
//  Copyright © 2016 Duc Dinh. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {

  @IBOutlet weak var selectionLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
