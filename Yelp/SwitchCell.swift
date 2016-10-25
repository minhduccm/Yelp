//
//  SwitchCell.swift
//  Yelp
//
//  Created by Duc Dinh on 10/23/16.
//  Copyright © 2016 Duc Dinh. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
  @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value:Bool)
}

class SwitchCell: UITableViewCell {
  
  @IBOutlet weak var switchLabel: UILabel!
  @IBOutlet weak var onSwitch: UISwitch!
  
  weak var switchCellDelegate: SwitchCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    onSwitch.addTarget(self, action: #selector(SwitchCell.switchValueChanged), for: UIControlEvents.valueChanged)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func switchValueChanged() {
    switchCellDelegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
  }

}
