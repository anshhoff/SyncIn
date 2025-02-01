//
//  MapView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default SF
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var mapType: MKMapType = .standard
    @State private var showsUserLocation = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            UIKitMapView(region: $region, mapType: $mapType, showsUserLocation: $showsUserLocation)
                .edgesIgnoringSafeArea(.all)
                .onAppear { checkLocationAuthorization() }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    // 📍 "Locate Me" Button
                    Button(action: centerOnUserLocation) {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 10)

                    // 🗺 Map Type Toggle (Standard / Satellite)
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
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // More zoom
        )
        showsUserLocation = true
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

// 📍 UIKit-based MapView to support map type changes
struct UIKitMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var mapType: MKMapType
    @Binding var showsUserLocation: Bool
    
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
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapView
        
        init(_ parent: UIKitMapView) {
            self.parent = parent
        }
    }
}

// 📍 Location Manager for user permissions & updates
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

#Preview {
    MapView()
}
