//
//  AircraftDataEnum.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/11/26.
//  Used to convert the aircraft details to readable types or (ideally) strings

enum AircraftDataEnum: CaseIterable {
    case flight
    case registration
    case ownerOperatorYear
    case altGeom
    case position
    case squawk
    case emergency
    case tas
    
    var title: String {
        switch self {
        case .flight:
            return "Flight"
        case .registration:
            return "Registration"
        case .ownerOperatorYear:
            return "Owner/Operator, Year"
        case .altGeom:
            return "Geo Alt"
        case .position:
            return "Position"
        case .squawk:
            return "Squawk"
        case .tas:
            return "True Air Speed"
        case .emergency:
            return "Emergency"
        }
    }
    
    func value(from aircraft: Aircraft) -> String {
        switch self {
        case .flight:
            return aircraft.flight ?? "NULL"
        case .registration:
            return aircraft.registration ?? "NULL"
        case .ownerOperatorYear:
            return "\(aircraft.ownerOperator ?? "NULL"), \(aircraft.year ?? "NULL")"
        case .altGeom:
            if let aircraftGeo = aircraft.altGeom {
                return "\(aircraftGeo)"
            }
            return "NULL"
        case .position:
            if let lat = aircraft.latitude, let lon = aircraft.longitude{
                return "(\(lat), \(lon))"
            }
            return "NULL"
        case .squawk:
            return aircraft.squawk ?? "NULL"
        case .tas:
            if let tas = aircraft.tas {
                return "\(tas)"
            }
            return "NULL"
        case .emergency:
            return aircraft.emergency ?? "NULL"
        }
    }
}
