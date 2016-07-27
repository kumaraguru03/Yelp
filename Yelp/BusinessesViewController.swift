//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,FiltersViewControllerDelegate {

    let clatitude = 37.785771
    let clongitude = -122.406165

    var businesses: [Business]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    // Filter variables
    var categories: [String]?
    var deals = false
    var radius:Int?
    var sort : YelpSortMode?

    let searchBar = UISearchBar()
    var searchTerm: String?
    
    enum ViewMode: String {
        case List = "List"
        case Map = "Map"
    }
    
    var currentView = ViewMode.List

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        mapView.hidden = true
        
        // Add search box in navigation bar
        self.searchBar.sizeToFit()
        self.searchBar.delegate = self
        navigationItem.titleView = self.searchBar

        // Perform initial search for Thai food
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()

            // Pin the businesses in the map view
            self.addAnnotationForBusinesses(self.businesses)

            // Just printing
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })

        // to Zoom the map to san francisco
        goToLocation(CLLocation(latitude: clatitude, longitude: clongitude))


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

    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    private func addAnnotationForBusinesses(businesses: [Business]) {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        
        for business in businesses {
            let coordinate = CLLocationCoordinate2D(latitude: business.coordinate.latitude!, longitude: business.coordinate.longitude!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = business.name
            mapView.addAnnotation(annotation)
        }
        
        zoomMapToFitAnnotationsForBusiness(businesses)
    }
    
    private func zoomMapToFitAnnotationsForBusiness(businesses: [Business]) {
        let rectToDisplay = self.businesses.reduce(MKMapRectNull) { (mapRect: MKMapRect, business: Business) -> MKMapRect in
            let coordinate = CLLocationCoordinate2D(latitude: business.coordinate.latitude!, longitude: business.coordinate.longitude!)
            let businessPointRect = MKMapRect(origin: MKMapPointForCoordinate(coordinate), size: MKMapSize(width: 0, height: 0))
            return MKMapRectUnion(mapRect, businessPointRect)
        }
        self.mapView.setVisibleMapRect(rectToDisplay, edgePadding: UIEdgeInsetsMake(74, 20, 20, 20), animated: false)
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
    
    @IBAction func toggleMapAndListViews(sender: UIBarButtonItem) {
        if currentView == .List {
            currentView = .Map
            UIView.transitionWithView(
                view,
                duration: 0.5,
                options: [.TransitionFlipFromRight],
                animations: {
                    self.tableView.hidden = true
                    self.mapView.hidden = false
                },
                completion: nil
            )
            sender.title = "List"
        } else {
            currentView = .List
            UIView.transitionWithView(
                view,
                duration: 0.5,
                options: [.TransitionFlipFromLeft],
                animations: {
                    self.tableView.hidden = false
                    self.mapView.hidden = true
                },
                completion: nil
            )
            sender.title = "Map"
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // delegate method call
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        categories = filters["categories"] as? [String]
        
        if (filters["deals"] != nil) {
            if (filters["deals"] as! String == "1") {
                deals = true
            }
        }
        
        if (filters["radius"] != nil) {
            radius = Int(filters["radius"] as! String)!
        }
        
        if (filters["sort"] != nil) {
            let sortState = filters["sort"] as! String
        
            switch(sortState) {
                case "1":
                    sort = YelpSortMode.Distance
                case "2":
                    sort = YelpSortMode.HighestRated
                default:
                    sort = YelpSortMode.BestMatched
            }
        }
        
        Business.searchWithTerm("Restaurants", sort: sort, categories: categories, deals: deals, radius: radius) {
            (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.addAnnotationForBusinesses(self.businesses)
        }

    }
    
    // Search Bar Delegate Methods
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchTerm = searchBar.text!
        searchBar.resignFirstResponder()
        
        print("searching for..." + searchTerm!)
        
        Business.searchWithTerm(searchTerm!, sort: sort, categories: categories, deals: deals, radius: radius) {
            (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.addAnnotationForBusinesses(self.businesses)
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
