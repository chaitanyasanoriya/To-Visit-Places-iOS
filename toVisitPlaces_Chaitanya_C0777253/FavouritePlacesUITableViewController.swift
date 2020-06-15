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
    private var mPlaces: [Place] = []
    private var cellReuseIdentifier = "reuse"
    private var mPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mPlaces = PlacesHelper.getInstance().getPlaces()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground()
    {
        PlacesHelper.getInstance().savePlaces()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        self.mPlaces = PlacesHelper.getInstance().getPlaces()
        print("self.mPlaces.count \(self.mPlaces.count)")
        return self.mPlaces.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: self.cellReuseIdentifier)
        }
        cell?.textLabel?.text = self.mPlaces[indexPath.row].title
        cell?.detailTextLabel?.text = self.mPlaces[indexPath.row].subtitle
        cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
        let image_view = UIImageView(image: UIImage(systemName: "greaterthan"))
        cell?.accessoryView = image_view
        //print("self.mPlaces[indexPath.row].title \(self.mPlaces[indexPath.row].title)")
        return cell!
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mPlace = mPlaces[indexPath.row]
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        mPlace = nil
        self.mTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" && mPlace != nil
        {
            let vc = segue.destination as! ViewController
            vc.mPlace = mPlace!
            vc.mAlreadyStarred = true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            PlacesHelper.getInstance().remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
