//
//  RadarView.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/11/26.
//

import SwiftUI

struct RadarView: View {
    @State private var sweepAngle: Angle = .degrees(0)
    
    private let sweepDuration: TimeInterval = 10.0
    
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
                        Path(ellipseIn: CGRect(
                            x: center.x - r,
                            y: center.y - r,
                            width: r * 2,
                            height: r * 2
                        )),
                        with: .color(.green.opacity(0.25))
                    )
                }
                
                var sweepPath = Path()
                sweepPath.move(to: center)
                
                // Radar Sweep
                let time = timeline.date.timeIntervalSinceReferenceDate
                let progress = time.truncatingRemainder(
                    dividingBy: sweepDuration
                ) / sweepDuration
                
                let angle = progress * 2 * .pi
                
                let end = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )
                
                sweepPath.addLine(to: end)
                                
                context.stroke(
                    sweepPath,
                    with: .color(.green.opacity(0.75)),
                    style: .init(lineWidth: 2))
                
                
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
