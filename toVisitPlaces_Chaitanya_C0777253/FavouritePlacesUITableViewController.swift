//
//  FavouritePlacesUITableViewController.swift
//  toVisitPlaces_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 13/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class FavouritePlacesUITableViewController: UITableViewController {
    
    @IBOutlet var mTableView: UITableView!
    private var cellReuseIdentifier = "reuse"
    private var mPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    /// Function Called when the Application is no longer going to be active. This function triggers the save of all the places in the User Defaults
    @objc func appMovedToBackground()
    {
        PlacesHelper.getInstance().savePlaces()
    }
    
    /// Built-in function, called to get number of rows to be added in table view.
    /// - Parameters:
    ///   - tableView: TableView which is being populated
    ///   - section: Section for which this function is being called
    /// - Returns: Number of Rows in this section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlacesHelper.getInstance().getNumberOfPlaces()
    }
    
    /// Built-in function, called to get the row for this index
    /// - Parameters:
    ///   - tableView: TableView which is being populated
    ///   - indexPath: IndexPath whose row is being asked
    /// - Returns: Table Cell with data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: self.cellReuseIdentifier)
        }
        let place = PlacesHelper.getInstance().getPlace(at: indexPath.row)
        cell?.textLabel?.text = place.title
        cell?.detailTextLabel?.text = place.subtitle
        cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
        let image_view = UIImageView(image: UIImage(systemName: "greaterthan"))
        cell?.accessoryView = image_view
        return cell!
    }
    
    
    /// Built-in function, called when a row is tapped. Performs a segue to View Controller for the row which is tapped
    /// - Parameters:
    ///   - tableView: TableView whose Row is tapped
    ///   - indexPath: IndexPath of the row tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mPlace = PlacesHelper.getInstance().getPlace(at: indexPath.row)
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
    /// Built-in function, called when the View is going to disappear. This function will hide the navigation bar for Map View Controller
    /// - Parameter animated: tells if the disappearance will animate
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /// Built-in function, called when the View is going to appear. This function will show the navigation bar for Map View Controller
    /// - Parameter animated: tells if the appearance will animate
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        mPlace = nil
        self.mTableView.reloadData()
    }
    
    /// Built-in function, called when segue is being performed. This function will pass the Favourite Place's data to the Map View Controller
    /// - Parameters:
    ///   - segue: segue that is being performed
    ///   - sender: who has called performsegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" && mPlace != nil
        {
            let vc = segue.destination as! ViewController
            vc.mPlace = mPlace!
            vc.mAlreadyStarred = true
        }
    }
    
    /// Built-in function, called when a row is being edited. This function will perform to swipe to delete functionality
    /// - Parameters:
    ///   - tableView: TableView whose row is being edited
    ///   - editingStyle: the editing style that is being performed
    ///   - indexPath: indexpath of the row being edited
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            PlacesHelper.getInstance().remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
