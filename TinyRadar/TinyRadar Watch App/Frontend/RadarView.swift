//
//  RadarView.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/11/26.
//

import SwiftUI

struct RadarView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel

    private let sweepDuration: TimeInterval = 15
    
    @State private var aircraftList: [Aircraft] = []
    @State private var userLat: Double = 0
    @State private var userLon: Double = 0
    @State private var cRadius: Double = 0
    @State private var liveTimer: Timer? = nil
    @State private var centerPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    let connection: Connect = Connect()
    let gradient = Gradient(stops: [
        .init(color: .green.opacity(0.35), location: 0.0),
        .init(color: .green.opacity(0.15), location: 0.5),
        .init(color: .green.opacity(0.01), location: 1.0)
    ])

    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                GeometryReader { proxy in
                    Canvas { context, size in
                        let radius = min(size.width, size.height) / 2
                        
                        // Radar Distance Rings
                        for fraction in [0.10, 0.25, 0.5, 0.75, 1.0] {
                            let r = radius * fraction
                            
                            context.stroke(
                                Path(
                                    ellipseIn: CGRect(
                                        x: centerPoint.x - r,
                                        y: centerPoint.y - r,
                                        width: r * 2,
                                        height: r * 2
                                    )
                                ),
                                with: .color(.green.opacity(0.25))
                            )
                        }
                        
                        // Radar Sweep
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        let progress = -time.truncatingRemainder(
                            dividingBy: sweepDuration
                        ) / sweepDuration
                        
                        let angle = progress * 2 * .pi
                        let trailAngle = Swift.Double.pi * 2 // 360° radar
                        let startAngle = angle - trailAngle
                        
                        var sweepPath = Path()
                        
                        sweepPath.move(to: centerPoint)
                        
                        // Outer arc
                        sweepPath.addArc(
                            center: centerPoint,
                            radius: radius,
                            startAngle: Angle(radians: startAngle),
                            endAngle: Angle(radians: angle),
                            clockwise: false
                        )
                        
                        // Connect to inner arc
                        sweepPath.addLine(to: centerPoint)
                        
                        sweepPath.closeSubpath()
                        
                        // Fill the sweep
                        context.fill(
                            sweepPath,
                            with: .conicGradient(
                                gradient,
                                center: centerPoint,
                                angle: Angle(radians: startAngle))
                        )
                        
                        // Center Marking (user position)
                        context.fill(
                            Path(
                                ellipseIn: CGRect(
                                    x: centerPoint.x - 3,
                                    y: centerPoint.y - 3,
                                    width: 6,
                                    height: 6
                                )
                            ),
                            with: .color(.blue.opacity(0.60))
                        )
                    }
                    HStack {}
                        .onAppear {
                            guard let location = locationViewModel.userLocation else {
                                return
                            }
                            
                            userLat = location.latitude
                            userLon = location.longitude
                            
                            cRadius = min(proxy.size.width / 2, proxy.size.height / 2)
                                
                            centerPoint = CGPoint(
                                x: proxy.size.width / 2,
                                y: proxy.size.height / 2
                            )
                            
                            let timer = Timer(timeInterval: 30, repeats: true) { _ in
                                Task { @MainActor in
                                    aircraftList = await connection.updateFlights(lat: userLat, lon: userLon, radius: 250)
                                }
                            }
                            RunLoop.current.add(timer, forMode: .common)
                            liveTimer = timer
                            liveTimer?.fire()
                        }
                }
            }
            
            ForEach(aircraftList.filter( {
                $0.latitude != nil && $0.longitude != nil
            } )) { aircraft in
                Image(systemName: "airplane")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees((aircraft.trueHeading ?? aircraft.track ?? 0) - 90))
                    .position(aircraftPositionToPoint(aircraftLat: aircraft.latitude!, aircraftLon: aircraft.longitude!))
            }
        }
    }
    
    private func aircraftPositionToPoint(aircraftLat: Double, aircraftLon: Double) -> CGPoint {
        
        var latDiff = (abs(aircraftLon) - abs(userLon)) * 111.2 // KM
        var lonDiff = (abs(aircraftLon) - abs(userLon)) * 79.64 // KM
        
        let distancePerPixel = 231.5 / cRadius

        if abs(aircraftLon) - abs(userLon) < 0 {
            lonDiff = -lonDiff
        }
        if abs(aircraftLat) - abs(userLat) < 0 {
            latDiff = -latDiff
        }
        
        let distanceFromCenterX = centerPoint.y + (latDiff / distancePerPixel)
        let distanceFromCenterY = centerPoint.x + (lonDiff / distancePerPixel)
        
        let resultingPoint = CGPoint(x: distanceFromCenterX, y: distanceFromCenterY)
        
        print(resultingPoint)
        return resultingPoint
    }
}
