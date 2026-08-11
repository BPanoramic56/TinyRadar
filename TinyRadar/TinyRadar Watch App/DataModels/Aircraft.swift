//
//  Flights.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

struct Aircraft: Codable, Identifiable {
    var id: String { hex }

    let hex: String
    let type: String?

    let flight: String?
    let registration: String?
    let aircraftType: String?
    let desc: String?
    let ownerOperator: String?
    let year: String?

    let altBaro: Altitude?
    let altGeom: Int?

    let groundSpeed: Double?
    let tas: Double?
    let track: Double?
    let trueHeading: Double?
    let baroRate: Int?

    let squawk: String?
    let emergency: String?
    let category: String?

    let navQnh: Double?
    let navAltitudeMcp: Int?
    let navHeading: Double?

    let latitude: Double?
    let longitude: Double?

    let nic: Int?
    let rc: Int?
    let seenPosition: Double?

    let version: Int?
    let nicBaro: Int?
    let nacP: Int?
    let nacV: Int?
    let sil: Int?
    let silType: String?
    let gva: Int?
    let sda: Int?

    let alert: Int?
    let spi: Int?

    let mlat: [String]
    let tisb: [String]

    let messages: Int?
    let seen: Double?
    let rssi: Double?

    let distance: Double?
    let direction: Double?

    enum CodingKeys: String, CodingKey {
        case hex
        case type

        case flight
        case registration = "r"
        case aircraftType = "t"
        case desc
        case ownerOperator = "ownOp"
        case year

        case altBaro = "alt_baro"
        case altGeom = "alt_geom"

        case groundSpeed = "gs"
        case tas
        case track
        case trueHeading = "true_heading"
        case baroRate = "baro_rate"

        case squawk
        case emergency
        case category

        case navQnh = "nav_qnh"
        case navAltitudeMcp = "nav_altitude_mcp"
        case navHeading = "nav_heading"

        case latitude = "lat"
        case longitude = "lon"

        case nic
        case rc
        case seenPosition = "seen_pos"

        case version
        case nicBaro = "nic_baro"
        case nacP = "nac_p"
        case nacV = "nac_v"
        case sil
        case silType = "sil_type"
        case gva
        case sda

        case alert
        case spi

        case mlat
        case tisb

        case messages
        case seen
        case rssi

        case distance = "dst"
        case direction = "dir"
    }
}
