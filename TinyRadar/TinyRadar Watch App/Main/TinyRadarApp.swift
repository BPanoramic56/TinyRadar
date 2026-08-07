//
//  TinyRadarApp.swift
//  TinyRadar Watch App
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

import SwiftUI

@main
struct TinyRadar_Watch_AppApp: App {
    @StateObject var locationViewModel: LocationViewModel = LocationViewModel()
    
    @State private var lamin: Double = 0
    @State private var lomin: Double = 0
    @State private var lamax: Double = 0
    @State private var lomax: Double = 0
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationViewModel)
        }
    }
}
