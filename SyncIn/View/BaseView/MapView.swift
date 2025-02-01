//
//  MapView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

// First, add the LocationManager class
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

// Model for user location data
struct UserLocation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let name: String
    let lastUpdated: Date
}

class NearbyUsersManager: ObservableObject {
    private let db = Firestore.firestore()
    @Published var nearbyUsers: [UserLocation] = []
    
    func updateUserLocation(latitude: Double, longitude: Double) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let locationData: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "lastUpdated": FieldValue.serverTimestamp(),
            "name": Auth.auth().currentUser?.displayName ?? "Anonymous"
        ]
        
        db.collection("user_locations").document(userId).setData(locationData) { error in
            if let error = error {
                print("Error updating location: \(error)")
            }
        }
    }
    
    func startListeningForNearbyUsers(centerLocation: CLLocation, radiusInKm: Double = 5.0) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let center = centerLocation.coordinate
        let radius = radiusInKm / 111.32 // Rough conversion from km to degrees
        
        db.collection("user_locations")
            .whereField("latitude", isGreaterThan: center.latitude - radius)
            .whereField("latitude", isLessThan: center.latitude + radius)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching nearby users: \(error)")
                    return
                }
                
                self.nearbyUsers = snapshot?.documents
                    .filter { $0.documentID != currentUserId }
                    .compactMap { document -> UserLocation? in
                        let data = document.data()
                        guard let latitude = data["latitude"] as? Double,
                              let longitude = data["longitude"] as? Double,
                              let name = data["name"] as? String else {
                            return nil
                        }
                        
                        let coordinate = CLLocationCoordinate2D(
                            latitude: latitude,
                            longitude: longitude
                        )
                        
                        return UserLocation(
                            id: document.documentID,
                            coordinate: coordinate,
                            name: name,
                            lastUpdated: (data["lastUpdated"] as? Timestamp)?.dateValue() ?? Date()
                        )
                    } ?? []
            }
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var nearbyUsersManager = NearbyUsersManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 28.7041, longitude: 77.1025),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var mapType: MKMapType = .standard
    @State private var showsUserLocation = false
    
    var body: some View {
        ZStack {
            UIKitMapView(
                region: $region,
                mapType: $mapType,
                showsUserLocation: $showsUserLocation,
                nearbyUsers: nearbyUsersManager.nearbyUsers
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                checkLocationAuthorization()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: centerOnUserLocation) {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 10)
                    
                    Button(action: {
                        mapType = (mapType == .standard) ? .satellite : .standard
                    }) {
                        Image(systemName: mapType == .standard ? "map" : "globe")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 10)
                }
            }
        }
    }
    
    private func centerOnUserLocation() {
        guard let userLocation = locationManager.location else { return }
        region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        showsUserLocation = true
        
        nearbyUsersManager.updateUserLocation(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude
        )
        
        nearbyUsersManager.startListeningForNearbyUsers(centerLocation: userLocation)
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            showsUserLocation = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

struct UIKitMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var mapType: MKMapType
    @Binding var showsUserLocation: Bool
    let nearbyUsers: [UserLocation]
    
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.mapType = mapType
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.mapType = mapType
        uiView.showsUserLocation = showsUserLocation
        
        let existingAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) }
        uiView.removeAnnotations(existingAnnotations)
        
        let newAnnotations = nearbyUsers.map { user -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = user.coordinate
            annotation.title = user.name
            return annotation
        }
        
        uiView.addAnnotations(newAnnotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapView
        
        init(_ parent: UIKitMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
            
            let identifier = "NearbyUser"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}

#Preview {
    MapView()
}
