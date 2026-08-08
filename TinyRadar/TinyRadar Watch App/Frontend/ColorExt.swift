//
//  ColorExt.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/8/26.
//

import SwiftUI

// Taken from https://stackoverflow.com/questions/56874133/use-hex-color-in-swiftui
// Used to simplify JSON encoding
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Conforms to codable, while Color doesn't
    func toHex() -> String? {
        if let components = UIColor(self).cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return String(format: "#%02lX%02lX%02lX",
                          lround(Double(r * 255)),
                          lround(Double(g * 255)),
                          lround(Double(b * 255))
            )
        }
        return nil
    }
}
