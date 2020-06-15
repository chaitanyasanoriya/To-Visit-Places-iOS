//
//  Places+CoreDataProperties.swift
//  toVisitPlaces_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 14/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//
//


/// Model Class Place which inherits Codable, which helps in ecoding and decoding the Class Object
class Place: Codable
{

    public var longitude: Double
    public var latitude: Double
    public var title: String
    public var subtitle: String?
    
    init(longitude: Double, latitude: Double, title: String, subtitle: String?)
    {
        self.longitude = longitude
        self.latitude = latitude
        self.title = title
        self.subtitle = subtitle
    }
}
