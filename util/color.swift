//
//  color.swift
//  machat
//
//  Created by chenhaifeng on 2024/3/29.
//

import SwiftUI

func hexToColor(hex: String) -> Color {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    let r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
        (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
    default:
        (r, g, b) = (1, 1, 1) // Default to white if invalid format
    }

    return Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
}

let primaryColor = hexToColor(hex: "#4496ff")
let bgColor1 = hexToColor(hex: "#3c91f1")
let bgColor2 = hexToColor(hex: "#4496ff")
let containerBg = hexToColor(hex: "#ededec")
