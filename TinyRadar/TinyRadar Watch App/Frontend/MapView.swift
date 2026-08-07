//
//  MapView.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    @FocusState private var mapFocused: Bool

    let connection: Connect = Connect()

    @State private var aircraftList: [Aircraft] = []
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var liveTimer: Timer? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var zoom = 200.0
    @State private var debounceTask: Task<Void, Never>?

    private let metersPerNauticalMile = 1852.0
    private let maxRadiusNM = 250.0

    private var radiusNM: Double {
        min(zoom / metersPerNauticalMile, maxRadiusNM)
    }
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: []){
            
            if locationViewModel.userLocation != nil {
                UserAnnotation(anchor: .center)
            }
            
            ForEach(aircraftList.filter( {
                $0.latitude != nil && $0.longitude != nil
            } )) { aircraft in
                Annotation(
                    aircraft.flight?.trimmingCharacters(in: .whitespaces) ?? "UNIDENT",
                    coordinate: CLLocationCoordinate2D(
                        latitude: aircraft.latitude!,
                        longitude: aircraft.longitude!
                    )
                ) {
                    Image(systemName: "airplane")
                        .font(.system(size: 12))
                        .rotationEffect(.degrees((aircraft.trueHeading ?? aircraft.track ?? 0) - 90))
                }
            }
        }
        .mapControlVisibility(.hidden)
        .focusable(true)
        .focused($mapFocused)
        .digitalCrownRotation(
            $zoom,
            from: 250,
            through: 250000,
            by: 12500,
            isContinuous: false
        )
        .onAppear() {
            mapFocused = true
            setInitialCamera()
        }
        .onChange(of: zoom, { oldValue, newValue in
            updateCameraDistance()
        })
        .onAppear() {
            let timer = Timer(timeInterval: 30, repeats: true) { _ in
                Task {
                    await updateFlights()
                }
            }
            RunLoop.current.add(timer, forMode: .common)
            liveTimer = timer
            liveTimer?.fire()
        }
    }
    
    @MainActor
    private func updateFlights() async {
        do {
            aircraftList = try await connection.performCall(
                lat: latitude,
                long: longitude,
                radius: radiusNM
            )
            
//            print("Aircraft count:", aircraftList.count)
//            
//            for aircraft in aircraftList {
//                print(
//                    aircraft.flight ?? "NO FLIGHT",
//                    aircraft.latitude ?? 0,
//                    aircraft.longitude ?? 0
//                )
//            }
        }
        catch {
            print("Error updating flights: \(error.localizedDescription)")
        }
    }
    
    private func setInitialCamera() {
        guard let location = locationViewModel.userLocation else {
            return
        }

        latitude = location.latitude
        longitude = location.longitude

        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: location,
                distance: zoom
            )
        )
    }
    
    private func updateCameraDistance() {
        guard let location = locationViewModel.userLocation else {
            return
        }

        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: location,
                distance: zoom
            )
        )
    }
}
