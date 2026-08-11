//
//  AircraftResponse.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/11/26.
//

struct AircraftResponse: Codable {
    let ac: [Aircraft]
    let msg: String
    let now: Int64
    let total: Int
    let ctime: Int64
    let ptime: Int
}
