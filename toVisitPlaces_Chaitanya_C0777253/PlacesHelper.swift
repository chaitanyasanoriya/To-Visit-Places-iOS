//
//  PlaceHelper.swift
//  toVisitPlaces_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 14/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation

class PlacesHelper
{
    private var mPlaces: [Place]
    private var mUserDefaults: UserDefaults
    private static var mInstance: PlacesHelper?
    
    private init()
    {
        self.mPlaces = []
        self.mUserDefaults = UserDefaults.standard
        loadPlaces()
    }
    
    static func getInstance() -> PlacesHelper
    {
        if mInstance == nil
        {
            mInstance = PlacesHelper()
        }
        return mInstance!
    }
    
    private func loadPlaces()
    {
        //dump(mPlaces)
        if let data = UserDefaults.standard.data(forKey: "places")
        {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                
                // Decode Note
                let places = try decoder.decode([Place].self, from: data)
                self.mPlaces = places
                //dump(places)
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
        sortPlaces()
    }
    
    internal func getPlaces() -> [Place]
    {
        return self.mPlaces
    }
    
    private func setPlaces()
    {
        do
        {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            
            // Encode Note
            let data = try encoder.encode(self.mPlaces)
            
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: "places")
            //print("done")
            
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
    internal func removePlace(place: Place)
    {
        var i=0
        for place1 in self.mPlaces
        {
            if place1.latitude == place.latitude && place1.longitude == place.longitude
            {
                break
            }
            i+=1
        }
        mPlaces.remove(at: i)
    }
    
    private func sortPlaces()
    {
        self.mPlaces.sort { (place1, place2) -> Bool in
            if place1.title < place2.title
            {
                return true
            }
            return false
        }
    }
    
    internal func remove(at: Int)
    {
        self.mPlaces.remove(at: at)
    }
    
    internal func savePlaces()
    {
        setPlaces()
    }
    
    internal func addPlace(place: Place)
    {
        self.mPlaces.append(place)
        sortPlaces()
        //setPlaces()
    }
    
    internal func replace(oldPlace:Place, newPlace: Place)
    {
        var cond = false
        for place in self.mPlaces
        {
            if oldPlace.latitude == place.latitude && oldPlace.longitude == place.longitude
            {
                cond = true
                break
            }
        }
        if(cond)
        {
            removePlace(place: oldPlace)
            addPlace(place: newPlace)
        }
    }
    
    //    static func loadPlaces(context: NSManagedObjectContext)
    //    {
    //        //If the number of cars is zero
    //        //Creating a Request
    //        if(mPlaces.count == 0)
    //        {
    //            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")
    //
    //            //Creating a local variable
    //            var results: [NSManagedObject] = []
    //
    //            do {
    //                //Fetching all the rows into results
    //                results = try context.fetch(fetchRequest)
    //            }
    //            catch {
    //                print(error)
    //            }
    //
    //            //Looping for each result
    //            for result in results
    //            {
    //                let longitude: Double = Double(exactly: result.value(forKey: "longitude") as! NSNumber)!
    //                let latitude: Double = Double(exactly: result.value(forKey: "latitude") as! NSNumber)!
    //                let title: String = "\(result.value(forKey: "title") as! NSString)"
    //                let subtitle: String = "\(result.value(forKey: "title") as! NSString)"
    //
    //                //Creating a local variable car
    //                let place: Place = Place(longitude: longitude, latitude: latitude, title: title, subtitle: subtitle)
    //
    //                //Adding the car instance into Member Variable mCars
    //                PlacesHelper.mPlaces.append(place)
    //            }
    //
    //            //Sorting the fetched cars alphabetically
    //            sortPlaces()
    //        }
    //    }
    //
    //    static func getPlaces() -> [Place]
    //    {
    //        return PlacesHelper.mPlaces
    //    }
    //
    //    static func addPlace(place: Place, context: NSManagedObjectContext)
    //    {
    //        mPlaces.append(place)
    //        sortPlaces()
    //        savePlaceInDataBase(place: place, context: context)
    //    }
    //
    //    static func removePlace(place: Place, context: NSManagedObjectContext)
    //    {
    //        var i=0
    //        for place1 in mPlaces
    //        {
    //            if place1.latitude == place.latitude && place1.longitude == place.longitude
    //            {
    //                break
    //            }
    //            i+=1
    //        }
    //        mPlaces.remove(at: i)
    //        removePlaceFromDataBase(place: place, context: context)
    //    }
    //
    //    private static func savePlaceInDataBase(place: Place, context: NSManagedObjectContext)
    //    {
    //        //Creating a new Car entity
    //        let place_entity = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context)
    //
    //        //Setting the data into entity
    //        place_entity.setValue(place.longitude, forKey: "longitude")
    //        place_entity.setValue(place.latitude, forKey: "latitude")
    //        place_entity.setValue(place.title, forKey: "title")
    //        place_entity.setValue(place.subtitle, forKey: "subtitle")
    //        //Trying to save the entity into the database
    //        do
    //        {
    //            try context.save()
    //        }
    //        catch
    //        {
    //            //Prints error if there was a problem in saving the database
    //            print(error)
    //        }
    //    }
    //
    //    private static func removePlaceFromDataBase(place: Place, context: NSManagedObjectContext)
    //    {
    //        //Creating a Request
    //        let fetch_request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
    //
    //        //Setting the search criteria
    //        fetch_request.predicate = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [place.latitude, place.longitude])
    //        do
    //        {
    //            //Fetching the data
    //            let test = try context.fetch(fetch_request)
    //
    //            //Fetching the Car Object
    //            let object_to_delete = test[0] as! NSManagedObject
    //
    //            //Deleting the object
    //            context.delete(object_to_delete)
    //            do
    //            {
    //                //Saving the Database
    //                try context.save()
    //            }
    //            catch
    //            {
    //                //Prints error if encountered when saving
    //                print(error)
    //            }
    //        }
    //        catch
    //        {
    //            //Prints error if encountered when fetching
    //            print(error)
    //        }
    //    }
    //
    //    private static func sortPlaces()
    //    {
    //        PlacesHelper.mPlaces.sort { (place1, place2) -> Bool in
    //            if place1.title < place2.title
    //            {
    //                return true
    //            }
    //            return false
    //        }
    //    }
    //
    //    static func remove(at: Int, context: NSManagedObjectContext)
    //    {
    //        let place = mPlaces.remove(at: at)
    //        removePlaceFromDataBase(place: place, context: context)
    //    }
}
