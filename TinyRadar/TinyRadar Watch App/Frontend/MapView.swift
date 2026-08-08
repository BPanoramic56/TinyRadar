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
    @State private var zoom: Double = 12500.0
    @State private var debounceTask: Task<Void, Never>?
    
    @State private var selectedAircraftID: Aircraft.ID? = nil
    var selectedAircraft: Aircraft? {
        aircraftList.first {
            $0.id == selectedAircraftID
        }
    }
    @State private var showAircraftDetails: Bool = false

    private let metersPerNauticalMile: Double = 1852.0
    private let maxRadiusNM: Double = 250.0

    private var radiusNM: Double {
        min(zoom / metersPerNauticalMile, maxRadiusNM)
    }
    
    var body: some View {
        MapReader { mapProxy in
            GeometryReader { geometry in
                ZStack {
                    Map(position: $cameraPosition, interactionModes: []){
                        
                        if locationViewModel.userLocation != nil {
                            UserAnnotation(anchor: .center)
                        }
                        
                        ForEach(aircraftList.filter( {
                            $0.latitude != nil && $0.longitude != nil
                        } )) { aircraft in
                            
                            let airlineICAO: String = aircraft.flight?.trimmingCharacters(in: .whitespaces) ?? "N/A"
                            
                            let airlineColor = Color(
                                hex: AirlineColors.shared.airlineColor[
                                    String(airlineICAO.prefix(3))
                                ] ?? "#202020"
                            )
                            
                            Annotation(
                                airlineICAO,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: aircraft.latitude!,
                                    longitude: aircraft.longitude!
                                )
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(airlineColor)
                                        .frame(width: 20, height: 20)
                                    
                                    Image(systemName: "airplane")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                        .rotationEffect(.degrees((aircraft.trueHeading ?? aircraft.track ?? 0) - 90))
                                }
                                .onTapGesture {
                                    withAnimation {
                                        selectedAircraftID = aircraft.hex
                                    }
                                }
                            }
                        }
                    }
                    .mapControlVisibility(.hidden)
                    .focusable(true)
                    .focused($mapFocused)
                    .digitalCrownRotation(
                        $zoom,
                        from: 12500,
                        through: 250000,
                        by: 37500,
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
                    .overlay(alignment: .bottom){
                        if showAircraftDetails, let aircraft = selectedAircraft {
                            aircraftDetailsSheet(aircraft: aircraft)
                        }
                        else if let selection = selectedAircraft {
                            let airlineICAO: String = selection.flight?.trimmingCharacters(in: .whitespaces) ?? "N/A"
                            
                            let airlineColor = Color(
                                hex: AirlineColors.shared.airlineColor[
                                    String(airlineICAO.prefix(3))
                                ] ?? "#202020"
                            )
//                            connectingPath(proxy: mapProxy, geometry: geometry, airlineColor: airlineColor)
                            detailsAvailableTab(selection: selection)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func connectingPath(proxy: MapProxy, geometry: GeometryProxy, airlineColor: Color) -> some View {
        if let aircraft = selectedAircraft,
           let lat = aircraft.latitude,
           let lon = aircraft.longitude {
            
            let coordinate = CLLocationCoordinate2D(
                latitude: lat,
                longitude: lon
            )
            
            if let aircraftPoint: CGPoint = proxy.convert(
                coordinate,
                to: .local
            ) {
                
                Path { path in
                    let selectorPoint = CGPoint(
                        x: geometry.size.width / 2,
                        y: geometry.size.height - 25
                    )
                    
                    path.move(to: aircraftPoint)
                    path.addLine(to: selectorPoint)
                }
                .stroke(
                    .white.opacity(0.6),
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round,
                        dash: [3, 3]
                    )
                )
            }
        }
    }
    
    @ViewBuilder
    private func aircraftDetailsSheet(aircraft: Aircraft) -> some View {
        let airlineICAO: String = aircraft.flight?.trimmingCharacters(in: .whitespaces) ?? "N/A"
        
        let airlineColor = Color(
            hex: AirlineColors.shared.airlineColor[
                String(airlineICAO.prefix(3))
            ] ?? "#202020"
        )
        
        VStack {
            Divider()
            
            HStack {
                ZStack {
                    Circle()
                        .fill(airlineColor)
                        .frame(width: 20, height: 20)
                    Image(systemName: "airplane")
                        .font(.system(size: 14, weight: .bold))
                        .rotationEffect(.degrees((aircraft.trueHeading ?? aircraft.track ?? 0) - 90))
                }
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text(aircraft.flight ?? "N/A")
                            .font(.system(size: 15, weight: .bold))
                        manufacturerLogo(for: aircraft.desc)
                    }
                    
                    Text(selectedAircraft?.desc ?? "N/A")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showAircraftDetails.toggle()
                    selectedAircraftID = nil
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(airlineColor.opacity(0.5), lineWidth: 1)
                }
                .shadow(color: airlineColor.opacity(0.75), radius: 12)
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func detailsAvailableTab(selection: Aircraft) -> some View {
        VStack {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showAircraftDetails.toggle()
                }
            } label: {
                VStack(spacing: 3) {
                    Capsule()
                        .fill(.black.opacity(0.4))
                        .frame(width: 20, height: 2)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "airplane")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text(selection.flight ?? "Unknown")
                            .font(.system(size: 10))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .offset(y: 12)
        }

    }
    
    @ViewBuilder
    private func manufacturerLogo(for description: String?) -> some View {
        if let description {
            switch description {
            case _ where description.contains("EMBRAER"):
                Image("EmbraerLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 9, height: 9)
            default:
                EmptyView()
            }
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
