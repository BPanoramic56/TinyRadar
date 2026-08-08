//
//  AircraftConnector.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/8/26.
//

import SwiftUI

struct AircraftConnector: Shape {
    var aircraftPoint: CGPoint
    var selectorPoint: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: aircraftPoint)

        // Slightly curved connector
        let midpoint = CGPoint(
            x: (aircraftPoint.x + selectorPoint.x) / 2,
            y: (aircraftPoint.y + selectorPoint.y) / 2
        )

        path.addQuadCurve(
            to: selectorPoint,
            control: midpoint
        )

        return path
    }
}
