//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Duc Dinh on 10/23/16.
//  Copyright © 2016 Duc Dinh. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController, UITableViewDelegate {
  
  var businesses: [Business]!
  
  // search bar vars
  lazy var searchBar = UISearchBar()
  var isClearButtonClicked = false
  var isRemovingTextWithBackspace = false
  
  // filter criteria vars
  var filteredCategories = [String]()
  var filteredSort: YelpSortMode? = nil
  var filteredDeal: Bool = false
  var filterDistance: Int? = nil

  @IBOutlet weak var businessesTableView: UITableView!
  
  func loadData() {
    Business.searchWithTerm("Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
      if let businesses = businesses {
        self.businesses = businesses
        self.businessesTableView.reloadData()
      }
    })
  }
  
  func filterData() {
    // Display HUD right before the request is made
    MBProgressHUD.showAdded(to: self.view, animated: true)
    Business.searchWithTerm(searchBar.text!, sort: filteredSort, categories: filteredCategories, deals: filteredDeal, distance: filterDistance) { (businesses: [Business]?, error: Error?) -> Void in
      
      // Hide HUD once the network request comes back (must be done on main UI thread)
      MBProgressHUD.hide(for: self.view, animated: true)
      if let businesses = businesses {
        self.businesses = businesses
        self.businessesTableView.reloadData()
      }
    }
  }
  
  func initSearchBar() {
    searchBar.delegate = self
    searchBar.placeholder = "Restaurants"
    navigationItem.titleView = searchBar
  }
  
  func setupBusinessesTableView() {
    businessesTableView.dataSource = self
    businessesTableView.delegate = self
    
    businessesTableView.rowHeight = UITableViewAutomaticDimension
    businessesTableView.estimatedRowHeight = 120
  }
  
  func customNavigationBar() {
    if let navigationBar = navigationController?.navigationBar {
      navigationBar.barTintColor = UIColor.red
      navigationBar.tintColor = UIColor.white
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBusinessesTableView()
    initSearchBar()
    customNavigationBar()
    filterData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let navigationController = segue.destination as! UINavigationController
    let filterViewController = navigationController.topViewController as! FiltersViewController
    filterViewController.filtersViewControllerDelegate = self
  }
}

extension BusinessesViewController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if businesses != nil {
      return businesses.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = businessesTableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
    cell.business = self.businesses[indexPath.row]
    return cell
  }
}

extension BusinessesViewController : UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
    filterData()
    searchBar.endEditing(true)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
    searchBar.text = ""
    searchBar.endEditing(true)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
  }
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    if isClearButtonClicked {
      isClearButtonClicked = false
      return false
    }
    return true
  }
  
  func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    isRemovingTextWithBackspace = (NSString(string: searchBar.text!).replacingCharacters(in: range, with: text).characters.count == 0)
    return true
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.characters.count == 0 && !isRemovingTextWithBackspace {
      isClearButtonClicked = true
      filterData()
    }
  }
}

extension BusinessesViewController : FiltersViewControllerDelegate {
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    if filters["categories"] != nil {
      filteredCategories = (filters["categories"] as? [String])!
    }
    
    if filters["distance"] != nil {
      filterDistance = (filters["distance"] as? Int)!
    }
    
    if filters["sortBy"] != nil {
      filteredSort = YelpSortMode(rawValue: (filters["sortBy"] as? Int)!)
    }
    filterData()
  }
}
