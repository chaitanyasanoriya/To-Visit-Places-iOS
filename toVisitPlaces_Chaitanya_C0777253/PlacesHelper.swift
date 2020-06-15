//
//  PlaceHelper.swift
//  toVisitPlaces_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 14/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation

/// PlacesHelper Class that Helps in Maintaining all the Favourite Places. The class implements Singleton design Pattern
class PlacesHelper
{
    private var mPlaces: [Place]
    private var mUserDefaults: UserDefaults
    private static var mInstance: PlacesHelper?
    
    /// Private Constructor so that the instance can only be created from inside the class
    private init()
    {
        self.mPlaces = []
        self.mUserDefaults = UserDefaults.standard
        loadPlaces()
    }
    
    /// Static funtion to get the instance of this class
    /// - Returns: Instance of this class
    static func getInstance() -> PlacesHelper
    {
        if mInstance == nil
        {
            mInstance = PlacesHelper()
        }
        return mInstance!
    }
    
    /// Loads All the Places from the User Defaults and converts them into Places Array. Called only once in lifecyle of the app
    private func loadPlaces()
    {
        if let data = UserDefaults.standard.data(forKey: "places")
        {
            do {
                let decoder = JSONDecoder()
                let places = try decoder.decode([Place].self, from: data)
                self.mPlaces = places
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
        sortPlaces()
    }
    
    /// Gets the Place at a particular index
    /// - Parameter at: index of the place
    /// - Returns: Place object at the index "at"
    internal func getPlace(at: Int) -> Place
    {
        return self.mPlaces[at]
    }
    
    /// Gets the number of Places in Favourite Places
    /// - Returns: Number of Places
    internal func getNumberOfPlaces() -> Int
    {
        return self.mPlaces.count
    }
    
    /// Saves the Places Array into User Defaults
    private func setPlaces()
    {
        do
        {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.mPlaces)
            UserDefaults.standard.set(data, forKey: "places")
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
    /// Removes a particular place object from array
    /// - Parameter place: place object to be removed
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
    
    /// Function to sort the Places alphabetically by title
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
    
    /// Removes a Place from at a particular index
    /// - Parameter at: index of the place object to be removed from array
    internal func remove(at: Int)
    {
        self.mPlaces.remove(at: at)
    }
    
    /// Function to save Places in User Defaults. Called only when the Application is resigning
    internal func savePlaces()
    {
        setPlaces()
    }
    
    /// Function to add place into Favourite Places Array
    /// - Parameter place: Place to be added in array
    internal func addPlace(place: Place)
    {
        self.mPlaces.append(place)
        sortPlaces()
    }
    
    /// Function to replace an old place with a new place
    /// - Parameters:
    ///   - oldPlace: Place to be replaced
    ///   - newPlace: Place to be replaced with
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
}
