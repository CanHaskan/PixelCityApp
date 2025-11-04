//
//  Constants.swift
//  PixelCity
//
//  Created by Can Haskan on 29.10.2025.
//

import CoreLocation
import Foundation
import MapKit

let apiKey = "UkXbA8WJfLnD4ZQhRSgjhvVD9SiDWM0nmPh7-gUpRwU"
let BASE_URL = "https://api.unsplash.com"

func createUnsplashUrl(forSearchTerm searchTerm: String, photoCount: Int) -> String {
        
        let url = "\(BASE_URL)/search/photos"
        
        var components = URLComponents(string: url)!
        components.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "per_page", value: "\(photoCount)"),
            URLQueryItem(name: "client_id", value: apiKey)
        ]
        
        return components.url?.absoluteString ?? ""
}

func getPlaceName(for annotation: MKAnnotation, completion: @escaping (String) -> ()) {
    let geocoder = CLGeocoder()
    let centerMapPoint = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
    
    geocoder.reverseGeocodeLocation(centerMapPoint) { (placemarks, error) in
        guard let placemark = placemarks?.first else {
            completion("nature")
            return
        }
        
        let locationName = placemark.locality ?? placemark.name ?? "city"
        completion(locationName)
    }
}

func unsplashSearchUrl(withAnnotation annotation: MKAnnotation, andNumberOfPhotos number: Int, completion: @escaping (String) -> ()) {
    
    getPlaceName(for: annotation) { (locationName) in
        
        let finalUrl = createUnsplashUrl(forSearchTerm: locationName, photoCount: number)
        
        completion(finalUrl)
    }
}
