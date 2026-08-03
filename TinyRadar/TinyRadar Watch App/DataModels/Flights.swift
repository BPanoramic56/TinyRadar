//
//  Flights.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

struct Flight: Decodable {
    let icao24: String?
    let callsign: String?
    let origin_country: String?
    let time_position: Int?
    let last_contact: Int?
    let longitude: Double?
    let latitude: Double?
    let baro_altitude: Double?
    let on_ground: Bool?
    let velocity: Double?
    let true_track: Double?
    let vertical_rate: Double?
    let sensors: [Int]?
    let geo_altitude: Double?
    let squawk: String?
    let spi: Bool?
    let position_source: Int?
    let category: Int?
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        icao24 = try container.decode(String.self)
        callsign = try container.decodeIfPresent(String.self)
        origin_country = try container.decode(String.self)
        time_position = try container.decodeIfPresent(Int.self)
        last_contact = try container.decode(Int.self)
        longitude = try container.decodeIfPresent(Double.self)
        latitude = try container.decodeIfPresent(Double.self)
        baro_altitude = try container.decodeIfPresent(Double.self)
        on_ground = try container.decodeIfPresent(Bool.self)
        velocity = try container.decodeIfPresent(Double.self)
        true_track = try container.decodeIfPresent(Double.self)
        vertical_rate = try container.decodeIfPresent(Double.self)
        sensors = try container.decodeIfPresent([Int].self)
        geo_altitude = try container.decodeIfPresent(Double.self)
        squawk = try container.decodeIfPresent(String.self)
        spi = try container.decodeIfPresent(Bool.self)
        position_source = try container.decodeIfPresent(Int.self)
        category = try container.decodeIfPresent(Int.self)
    }
}
