//
//  MapView.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

import SwiftUI
import MapKit

struct MainView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    @State private var radarStyle: Bool = true
    
    var body: some View {
        Group {
            if radarStyle {
                RadarView()
                    .ignoresSafeArea()
            }
            else {
                MapView()
            }
        }
        .onLongPressGesture {
            radarStyle.toggle()
        }
    }
}
