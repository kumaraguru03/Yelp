//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate {

    var businesses: [Business]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()

        navigationItem.titleView = searchBar
        
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            self.tableView.reloadData()
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.nameLabel.text = businesses[indexPath.row].name
        cell.thumbView.setImageWithURL(businesses[indexPath.row].imageURL!)
        cell.categoriesLabel.text = businesses[indexPath.row].categories
        cell.addressLabel.text = businesses[indexPath.row].address
        cell.reviewsCountLabel.text = "\(businesses[indexPath.row].reviewCount!) Reviews"
        cell.ratingView.setImageWithURL(businesses[indexPath.row].ratingImageURL!)
        cell.distanceLabel.text = businesses[indexPath.row].distance

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        let categories = filters["categories"] as? [String]
        
        var deals = false
        
        if (filters["deals"] != nil) {
            if (filters["deals"] as! String == "1") {
                deals = true
            }
        }
        
        var radius:Int?
        
        if (filters["radius"] != nil) {
            radius = Int(filters["radius"] as! String)!
        }
        
        var sort : YelpSortMode?
        if (filters["sort"] != nil) {
            let sortState = filters["sort"] as! String
        
            switch(sortState) {
            case "1":
                sort = YelpSortMode.Distance
            case "2":
                sort = YelpSortMode.HighestRated
            default:
                YelpSortMode.BestMatched
            }
        }
        
        print(categories)
        print(deals)
        print(radius)
        print(sort)
        
        Business.searchWithTerm("Restaurants", sort: sort, categories: categories, deals: deals, radius: radius) {
            (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        let navigationController = segue.destinationViewController as! UINavigationController
        
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        
        // Pass the selected object to the new view controller.
        
        
    }

}
