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
    
    @State var initialCase: Int = 0
    
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
    
    let columns = [
        GridItem(.fixed(75)),
        GridItem(.fixed(75))
    ]
        
//    @State private var selectedMapStyleIndex: Int = 0
//    let mapStyles: [MapStyle] = [
//        .standard,
//        .imagery(elevation: .realistic),
//        .standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false)
//    ]
    
    var body: some View {
        MapReader { mapProxy in
            GeometryReader { geometry in
                ZStack {
                    Map(position: $cameraPosition, interactionModes: []){
                        
                        if locationViewModel.userLocation != nil {
                            UserAnnotation(anchor: .center)
                        }
                                                
                        // Filters to only planes with a defined (lat, lon)
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
                    .mapStyle(.standard)
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
                            Task { @MainActor in
                                aircraftList = await connection.updateFlights(lat: latitude, lon: longitude, radius: radiusNM)
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
                            //                            let airlineICAO: String = selection.flight?.trimmingCharacters(in: .whitespaces) ?? "N/A"
                            
                            //                            let airlineColor = Color(
                            //                                hex: AirlineColors.shared.airlineColor[
                            //                                    String(airlineICAO.prefix(3))
                            //                                ] ?? "#202020"
                            //                            )
                            //                            connectingPath(proxy: mapProxy, geometry: geometry, airlineColor: airlineColor)
                            
                            detailsAvailableTab(selection: selection)
                        }
                    }
                }
                //                .onLongPressGesture {
                //                    WKInterfaceDevice.current().play(.click)
                //                    selectedMapStyleIndex = (selectedMapStyleIndex + 1) % mapStyles.count
                //                }
                //                .grayscale(selectedMapStyleIndex == 1 ? 1.0 : 0.0)
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
            
            detailCard(aircraft: aircraft)
            
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
                    initialCase = 0 // Resets the horizontal scroll
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
    private func detailCard(aircraft: Aircraft) -> some View {
        let caseStep: Int = 4
        let dataCases: [AircraftDataEnum] = AircraftDataEnum.allCases
        let maxCase: Int = dataCases.count
        
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(dataCases[initialCase...min(initialCase + caseStep - 1, maxCase - 1)], id: \.self) { detail in
                VStack(alignment: .leading){
                    Text(detail.title)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    HStack {
                        if let imageName = detail.image(from: aircraft) {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 25, maxHeight: 25)
                        }
                        Text(detail.value(from: aircraft))
                            .font(.system(size: 10, weight: .bold))
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50, alignment: .leading)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        withAnimation(.linear(duration: 0.2)) {
                            if value.translation.width < 0 { // Right swipe
                                if initialCase + caseStep >= maxCase {
                                    initialCase = 0
                                }
                                else {
                                    initialCase += caseStep
                                }
                            }
                            else { // Left Swipe
                                if initialCase - caseStep < 0 {
                                    initialCase = max(0, maxCase) - caseStep
                                }
                                else {
                                    initialCase -= caseStep
                                }
                            }
                        }
                    }))
            }
        }
        .padding(.horizontal)
        .background(.ultraThinMaterial.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
//    
//    @MainActor
//    private func updateFlights() async {
//        do {
//            aircraftList = try await connection.performCall(
//                lat: latitude,
//                long: longitude,
//                radius: radiusNM
//            )
//        }
//        catch {
//            print("Error updating flights: \(error.localizedDescription)")
//        }
//    }
    
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
