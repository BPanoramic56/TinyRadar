//
//  RadarView.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/11/26.
//

import SwiftUI

struct RadarView: View {
    private let sweepDuration: TimeInterval = 12.0
    
    let gradient = Gradient(stops: [
        .init(color: .green.opacity(0.35), location: 0.0),
        .init(color: .green.opacity(0.15), location: 0.5),
        .init(color: .green.opacity(0.01), location: 1.0)
    ])

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(
                    x: size.width / 2,
                    y: size.height / 2
                )

                let radius = min(size.width, size.height) / 2

                // Radar Distance Rings
                for fraction in [0.10, 0.25, 0.5, 0.75, 1.0] {
                    let r = radius * fraction

                    context.stroke(
                        Path(
                            ellipseIn: CGRect(
                                x: center.x - r,
                                y: center.y - r,
                                width: r * 2,
                                height: r * 2
                            )
                        ),
                        with: .color(.green.opacity(0.25))
                    )
                }

                // MARK: Radar Sweep

                let time = timeline.date.timeIntervalSinceReferenceDate
                let progress = -time.truncatingRemainder(
                    dividingBy: sweepDuration
                ) / sweepDuration

                let angle = progress * 2 * .pi
                let trailAngle = Swift.Double.pi * 2 // 360° radar
                let startAngle = angle - trailAngle

                var sweepPath = Path()
                
                sweepPath.move(to: center)

                // Outer arc
                sweepPath.addArc(
                    center: center,
                    radius: radius,
                    startAngle: Angle(radians: startAngle),
                    endAngle: Angle(radians: angle),
                    clockwise: false
                )

                // Connect to inner arc
                sweepPath.addLine(to: center)

                sweepPath.closeSubpath()

                // Fill the sweep
                context.fill(
                    sweepPath,
                    with: .conicGradient(
                        gradient,
                        center: center,
                        angle: Angle(radians: startAngle))
                )

                // Center marking
                context.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: center.x - 3,
                            y: center.y - 3,
                            width: 6,
                            height: 6
                        )
                    ),
                    with: .color(.blue.opacity(0.60))
                )
            }
        }
    }
}
