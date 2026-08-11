//
//  Altitude.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/11/26.
//

enum Altitude: Codable {
    case feet(Int)
    case ground

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Int.self) {
            self = .feet(value)
        }
        else if let value = try? container.decode(String.self),
                  value == "ground" {
            self = .ground
        }
        else {
            throw DecodingError.typeMismatch(
                Altitude.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Altitude must be an integer or 'ground'"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .feet(let value):
            try container.encode(value)
        case .ground:
            try container.encode("ground")
        }
    }
}
