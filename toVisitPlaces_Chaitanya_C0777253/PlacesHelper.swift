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
    
    internal func getPlaces() -> [Place]
    {
        return self.mPlaces
    }
    
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
}
