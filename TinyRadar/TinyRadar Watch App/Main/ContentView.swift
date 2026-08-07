//
//  ContentView.swift
//  TinyRadar Watch App
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    let Connection: Connect = Connect()
    
    var body: some View {
        VStack {
            MapView()
        }
    }
}
