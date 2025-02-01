//
//  User.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct User: Identifiable {
    let id: String                // Changed from UUID to String for Firebase compatibility
    let name: String
    let bio: String
    let hobbies: String
    let likes: String
    let dislikes: String
    let photo: String
    let distance: Int
    var coordinate: CLLocationCoordinate2D?    // Added for location tracking
    
    // Default initializer to maintain compatibility with existing code
    init(id: String = UUID().uuidString,
         name: String,
         bio: String,
         hobbies: String,
         likes: String,
         dislikes: String,
         photo: String,
         distance: Int,
         coordinate: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.name = name
        self.bio = bio
        self.hobbies = hobbies
        self.likes = likes
        self.dislikes = dislikes
        self.photo = photo
        self.distance = distance
        self.coordinate = coordinate
    }
    
    // Initialize from Firestore data
    init?(document: QueryDocumentSnapshot, userLocation: CLLocation? = nil) {
        let data = document.data()
        
        guard let name = data["name"] as? String,
              let bio = data["bio"] as? String,
              let hobbies = data["hobbies"] as? String,
              let likes = data["likes"] as? String,
              let dislikes = data["dislikes"] as? String,
              let photo = data["photo"] as? String,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.bio = bio
        self.hobbies = hobbies
        self.likes = likes
        self.dislikes = dislikes
        self.photo = photo
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Calculate distance if user location is available
        if let userLocation = userLocation {
            let userCoordinate = CLLocation(latitude: latitude, longitude: longitude)
            self.distance = Int(userLocation.distance(from: userCoordinate))
        } else {
            self.distance = 0
        }
    }
    
    // Convert User to Firestore data
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "bio": bio,
            "hobbies": hobbies,
            "likes": likes,
            "dislikes": dislikes,
            "photo": photo
        ]
        
        if let coordinate = coordinate {
            data["latitude"] = coordinate.latitude
            data["longitude"] = coordinate.longitude
        }
        
        return data
    }
}
