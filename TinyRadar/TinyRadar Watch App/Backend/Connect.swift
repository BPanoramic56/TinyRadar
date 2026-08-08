//
//  Connect.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//
//  Data gathered from OpenSky
//  Matthias Schäfer, Martin Strohmeier, Vincent Lenders, Ivan Martinovic and Matthias Wilhelm.
//  "Bringing Up OpenSky: A Large-scale ADS-B Sensor Network for Research".
//  In Proceedings of the 13th IEEE/ACM International Symposium on Information Processing in Sensor Networks (IPSN), pages 83-94, April 2014.
//  The OpenSky Network, https://opensky-network.org
//  https://opensky-network.org/api/states/all?lamin=45.8389&lomin=5.9962&lamax=47.8229&lomax=10.5226

import Foundation

struct Connect {
    func performCall(lat: Double, long: Double, radius: Double) async throws -> [Aircraft] {
        
        let url = URL(string: "https://api.airplanes.live/v2/point/\(lat)/\(long)/\(radius)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let flights = try JSONDecoder().decode(AircraftResponse.self, from: data)
        
        return flights.ac
    }
}
