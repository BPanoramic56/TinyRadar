//
//  ContentView.swift
//  TinyRadar Watch App
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @ObservedObject var locationViewModel: LocationViewModel = LocationViewModel()
    let Connection: Connect = Connect()
    
    @State private var lamin: Double = 0
    @State private var lomin: Double = 0
    @State private var lamax: Double = 0
    @State private var lomax: Double = 0
    @State private var liveTimer: Timer? = nil
    
    var body: some View {
        VStack {
            
        }
        .onAppear() {
            let timer = Timer(timeInterval: 1, repeats: true) { _ in
                if let location = locationViewModel.userLocation {
                    lamin = location.latitude - 1
                    lomin = location.longitude - 1
                    lamax = location.latitude + 1
                    lomax = location.longitude + 1
                }
            }
            RunLoop.current.add(timer, forMode: .common)
            liveTimer = timer
            liveTimer?.fire()
        }
    }
}
