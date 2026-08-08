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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationViewModel)
        }
    }
}
