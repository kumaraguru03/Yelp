//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Guru Vijayakumar on 7/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController,
                               didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    var categories: [[String:String]]!
    var sortTypes: [[String:String]]!
    var distances: [[String:String]]!
    var deals: [[String:String]]!

    var switchStates: [Int:[Int:Bool]] = [0:[0:false], 1:[0:false], 2:[0:false], 3:[0:false]]
    var dealState : Bool = false

    let titles = ["","Distance", "Sort By", "Category"]

    @IBOutlet weak var filterTableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTableView.delegate = self
        filterTableView.dataSource = self
        categories = yelpCategories()
        sortTypes = yelpSortTypes()
        distances = yelpDistances()
        deals = yelpDeals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var filters = [String : AnyObject]()
        var selectedCategories = [String]()
        
        for (row, isSelected) in switchStates[0]! {
            if (isSelected) {
                filters["deals"] = deals[row]["code"]!
            }
        }
        
        for (row, isSelected) in switchStates[1]! {
            if (isSelected) {
                filters["radius"] = distances[row]["code"]!
            }
        }
        
        for (row, isSelected) in switchStates[2]! {
            if (isSelected) {
                filters["sort"] = sortTypes[row]["code"]!
            }
        }
        
        for (row, isSelected) in switchStates[3]! {
            if (isSelected) {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"]  = selectedCategories
        }
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return 1
        case 1:
            return distances.count
        case 2:
            return sortTypes.count
        case 3:
            return categories.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section){
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = deals[indexPath.row]["name"]
            cell.delegate = self
            
            cell.onSwitch.on = switchStates[0]![indexPath.row] ?? false

            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = distances[indexPath.row]["name"]
            cell.delegate = self
            
            cell.onSwitch.on = switchStates[1]![indexPath.row] ?? false
            return cell

//            let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
//            let distanceIndex = distanceExpanded ? indexPath.row : distanceState
//            
//            cell.ddLabel.text = distances[indexPath.row]
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = sortTypes[indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = switchStates[2]![indexPath.row] ?? false
            return cell
            
//            let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
//            
//            cell.ddLabel.text = sortValues[indexPath.row]
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.delegate = self
            
            cell.onSwitch.on = switchStates[3]![indexPath.row] ?? false
            return cell

        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath)
            return cell

    }}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = filterTableView.indexPathForCell(switchCell)!
        let sectionIndex = indexPath.section
        switchStates[sectionIndex]![indexPath.row] = value
        
        if (sectionIndex == 1) {
            for (row, _) in switchStates[1]! {
                if (row != indexPath.row) {
                    switchStates[sectionIndex]![row] = false
                }
            }
        }
        if (sectionIndex == 2) {
            for (row, _) in switchStates[2]! {
                if (row != indexPath.row) {
                    switchStates[sectionIndex]![row] = false
                }
            }
        }
        print("value.." + "\(indexPath.section)" + "\(indexPath.row)" + "\(value)")
    }

    func yelpDeals() -> [[String: String]] {
        return [
            ["name" : "Offering a Deal", "code": "1"]]
    }

    func yelpDistances() -> [[String: String]] {
        return [
            ["name" : "Auto", "code": "0"],
            ["name" : "0.3 miles", "code": "482"],
            ["name" : "1 mile", "code": "1609"],
            ["name" : "5 mile", "code": "8046"],
            ["name" : "20 mile", "code": "32186"]]
    }

    func yelpSortTypes() -> [[String: String]] {
        return [
            ["name" : "Best Match", "code": "0"],
            ["name" : "Distance", "code": "1"],
            ["name" : "Highest Rated", "code": "2"]]
    }
    
    func yelpCategories() -> [[String: String]] {
                return [
                      ["name" : "African", "code": "african"],
                      ["name" : "American, New", "code": "newamerican"],
                      ["name" : "American, Traditional", "code": "tradamerican"],
                      ["name" : "Australian", "code": "australian"],
                      ["name" : "Austrian", "code": "austrian"],
                      ["name" : "Baguettes", "code": "baguettes"],
                      ["name" : "Food Stands", "code": "foodstands"],
                      ["name" : "French", "code": "french"],
                      ["name" : "French Southwest", "code": "sud_ouest"],
                      ["name" : "Indian", "code": "indpak"],
                      ["name" : "Indonesian", "code": "indonesian"],
                      ["name" : "International", "code": "international"],
                      ["name" : "Irish", "code": "irish"],
                      ["name" : "Mexican", "code": "mexican"],
                      ["name" : "Middle Eastern", "code": "mideastern"],
                      ["name" : "Soup", "code": "soup"],
                      ["name" : "Thai", "code": "thai"],
                      ["name" : "Vegetarian", "code": "vegetarian"],
                      ["name" : "Venison", "code": "venison"],
                      ["name" : "Vietnamese", "code": "vietnamese"],
                      ["name" : "Wok", "code": "wok"],
                      ["name" : "Wraps", "code": "wraps"],
                      ["name" : "Yugoslav", "code": "yugoslav"]] }
}
