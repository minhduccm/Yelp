//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Duc Dinh on 10/23/16.
//  Copyright © 2016 Duc Dinh. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
  @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

struct FilterSection {
  var header: String
  var type: String
  var data: AnyObject
}

struct Category {
  var name: String
  var code: String
}

struct Distance {
  var name: String
  var value: Int
}

struct SortBy {
  var name: String
  var value: Int
}

class FiltersViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  weak var filtersViewControllerDelegate: FiltersViewControllerDelegate?

  var categorySwitchStates = [Int:Bool]()
  var selectedDistance: Int?
  var selectedSortBy: Int?
  var sections = [FilterSection]()
  
  func getCategories() -> [Category] {
    return [Category(name: "Afghan", code: "afghani"),
            Category(name: "African", code: "african"),
            Category(name: "American", code: "newamerican"),
            Category(name: "American, Traditional", code: "tradamerican")]
  }
  
  func getDistances() -> [Distance] {
    return [Distance(name: "1 Mile", value: 1609),
            Distance(name: "2 Miles", value: 3218),
            Distance(name: "5 Miles", value: 8046),
            Distance(name: "10 Miles", value: 16093)]
  }
  
  func getSortByItems() -> [SortBy] {
    return [SortBy(name: "Best Match", value: 0),
            SortBy(name: "Distance", value: 1),
            SortBy(name: "Hightest rate", value: 2)]
  }
  
  func buildSections() -> [FilterSection]{
    let categoriesSection = FilterSection(
      header: "Categories",
      type: "categories",
      data: getCategories() as AnyObject
    )
    
    let distancesSection = FilterSection(
      header: "Distances",
      type: "distances",
      data: getDistances() as AnyObject
    )
    
    let sortByItemsSection = FilterSection(
      header: "Sort By",
      type: "sortBy",
      data: getSortByItems() as AnyObject
    )
    
    return [categoriesSection, distancesSection, sortByItemsSection]
  }
  
  func customNavigationBar() {
    if let navigationBar = navigationController?.navigationBar {
      navigationBar.barTintColor = UIColor.red
      navigationBar.tintColor = UIColor.white
      navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    customNavigationBar()
    sections = buildSections()
    
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }
  
  @IBAction func onCancelButton(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func onSearchButton(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
    var filters = [String:AnyObject]()
    var selectedCategories = [String]()
    var categories = sections[0].data as? [Category]
    for (row, isSelected) in categorySwitchStates {
      if isSelected {
        selectedCategories.append((categories?[row].code)!)
      }
    }
    
    if selectedCategories.count > 0 {
      filters["categories"] = selectedCategories as AnyObject?
    }
    if selectedDistance != nil {
      filters["distance"] = selectedDistance as AnyObject?
    }
    if selectedSortBy != nil {
      filters["sortBy"] = selectedSortBy as AnyObject?
    }
    
    filtersViewControllerDelegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
  }
}

extension FiltersViewController : UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let itemsInSection = sections[section].data as! [AnyObject]
    return itemsInSection.count
    
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section].header
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch sections[indexPath.section].type {
    case "categories":
      let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
      print(sections[indexPath.section].data)
      let categories = sections[indexPath.section].data as? [Category]
      cell.switchLabel.text = categories?[indexPath.row].name
      cell.switchCellDelegate = self
      cell.onSwitch.isOn = categorySwitchStates[indexPath.row] ?? false
      return cell
      
    case "distances":
      let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
      var distances = sections[indexPath.section].data as? [Distance]
      cell.selectionLabel.text = distances?[indexPath.row].name
      return cell
      
    case "sortBy":
      let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
      var sortByItems = sections[indexPath.section].data as? [SortBy]
      cell.selectionLabel.text = sortByItems?[indexPath.row].name
      return cell
      
    default:
      return UITableViewCell()
    }
  }
}

extension FiltersViewController : UITableViewDelegate {
  func clearAllCheckedInSection(sectionIdx: Int) {
    for rowIdx in 0 ..< tableView.numberOfRows(inSection: sectionIdx) {
      if let cell = tableView.cellForRow(at: NSIndexPath(row: rowIdx, section: sectionIdx) as IndexPath) {
        cell.accessoryType = .none
      }
    }
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    clearAllCheckedInSection(sectionIdx: indexPath.section)
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
    
    let type = sections[indexPath.section].type
    if type == "distances" {
      let distances = sections[indexPath.section].data as? [Distance]
      selectedDistance = distances![indexPath.row].value
    } else if type == "sortBy" {
      let sortByItems = sections[indexPath.section].data as? [SortBy]
      selectedSortBy = sortByItems![indexPath.row].value
    }
    return indexPath
  }
}

struct Parameters {
  var type: String
  var values: AnyObject
}

extension FiltersViewController : SwitchCellDelegate {
  func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
    let indexPath = tableView.indexPath(for: switchCell)!
    let type = sections[indexPath.section].type
    if type == "categories" {
      categorySwitchStates[indexPath.row] = value
    }
  }
}
