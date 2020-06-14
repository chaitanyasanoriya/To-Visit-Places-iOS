//
//  PlaceHelper.swift
//  toVisitPlaces_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 14/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation
import CoreData

class PlacesHelper
{
    private static var mPlaces: [Place] = []
    
    static func loadPlaces(context: NSManagedObjectContext)
    {
        //If the number of cars is zero
        //Creating a Request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")
        
        //Creating a local variable
        var results: [NSManagedObject] = []
        
        do {
            //Fetching all the rows into results
            results = try context.fetch(fetchRequest)
        }
        catch {
            print(error)
        }
        
        //Looping for each result
        for result in results
        {
            let longitude: Double = Double(exactly: result.value(forKey: "longitude") as! NSNumber)!
            let latitude: Double = Double(exactly: result.value(forKey: "latitude") as! NSNumber)!
            let title: String = "\(result.value(forKey: "title") as! NSString)"
            let subtitle: String = "\(result.value(forKey: "title") as! NSString)"
            
            //Creating a local variable car
            let place: Place = Place(longitude: longitude, latitude: latitude, title: title, subtitle: subtitle)
            print(title)
            
            //Adding the car instance into Member Variable mCars
            PlacesHelper.mPlaces.append(place)
        }
        
        //Sorting the fetched cars alphabetically
        PlacesHelper.mPlaces.sort { (place1, place2) -> Bool in
            if place1.title < place2.title
            {
                return true
            }
            return false
        }
        
    }
    
    static func getPlaces() -> [Place]
    {
        return PlacesHelper.mPlaces
    }
    
}
