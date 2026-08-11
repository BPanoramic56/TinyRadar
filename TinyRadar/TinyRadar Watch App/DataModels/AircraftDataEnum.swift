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
    case manufacturer
    case altGeom
    case geomRate
    case track
    case groundSpeed
    case position
    case squawk
    case emergency
    case navHeading
    
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
        case .geomRate:
            return "Geometric Altitude Change"
        case .position:
            return "Position"
        case .squawk:
            return "Squawk"
        case .emergency:
            return "Emergency"
        case .manufacturer:
            return "Manufacturer"
        case .navHeading:
            return "Heading"
        case .groundSpeed:
            return "Ground Speed"
        case .track:
            return "Track"
        }
    }
    
    func image(from aircraft: Aircraft) -> String? {
        switch self {
        case .manufacturer:
            if let mnft = aircraft.desc {
                switch (mnft){
                case _ where mnft.contains("AIRBUS"):
                    return "Airbus"
                case _ where mnft.contains("BOEING"):
                    return "Boeing"
                case _ where mnft.contains("EMBRAER"):
                    return "Embraer"
                case _ where mnft.contains("CESSNA"):
                    return "Cessna"
                case _ where mnft.contains("HAVILLAND"):
                    return "DeHavilland"
                case _ where mnft.contains("BOMBARDIER"):
                    return "Bombardier"
                default:
                    return nil
                }
            }
            
        case .ownerOperatorYear:
            if let ownerOperator = aircraft.ownerOperator {
                switch (ownerOperator) {
                case _ where ownerOperator.contains("HILLSBORO AERO ACADEMY"):
                    return "Hillsboro"
                default:
                    return nil
                }
            }
            
        default:
            return nil
        }
        
        return nil
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
                return "\(aircraftGeo)ft"
            }
            return "NULL"
        case .position:
            if let lat = aircraft.latitude, let lon = aircraft.longitude{
                return "\(lat), \(lon)"
            }
            return "NULL"
        case .squawk:
            return aircraft.squawk ?? "NULL"
        case .emergency:
            return aircraft.emergency ?? "NULL"
        case .manufacturer:
            if let manufacturer = aircraft.desc {
                return manufacturer
            }
            return "NULL"
        case .navHeading:
            if let th = aircraft.navHeading {
                return "\(th)"
            }
            return "NULL"
        case .geomRate:
            if let gr = aircraft.geomRate {
                return "\(gr)ft/min"
            }
            return "NULL"
        case .groundSpeed:
            if let gs = aircraft.groundSpeed {
                return "\(gs)kts"
            }
            return "NULL"
        case .track:
            if let t = aircraft.track {
                return "\(t)°"
            }
            return "NULL"
        }
    }
}
