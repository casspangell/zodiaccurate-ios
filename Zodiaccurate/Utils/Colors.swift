import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
    
    static let fontDateGradientStart = Color(hex: "8BBAFF")
    static let fontDateGradientEnd = Color(hex: "E5D7FF")
    
    static let textFieldBackground = Color(hex: "D0F0FF").opacity(0.5)
    
    static let backgroundPrimary = Color(hex: "15141B")
    static let backgroundSecondary = Color(hex: "18131C")
    static let accentGold = Color(hex: "E39D4D")
    static let accentPurple = Color(hex: "490073")
    static let accentBlue = Color(hex: "00324B")
    static let deepBlue = Color(hex: "00324B")
    static let navy = Color(hex: "0A1833")
    static let indigo = Color(hex: "1B2A4D")
    static let royalBlue = Color(hex: "4169E1")
    static let electricBlue = Color(hex: "7DF9FF")
    static let midnightBlue = Color(hex: "191970")
    static let sapphire = Color(hex: "0F52BA")
    static let azure = Color(hex: "007FFF")
    static let magenta = Color(hex: "D38DFC")
    static let deepPink = Color(hex: "FF1493")
    static let whiteCustom = Color(hex: "FFFFFF")
    static let grayCustom = Color(hex: "5A5A5A")
    static let utilsBackground = Color(hex: "#322447")
    static let accentGreen = Color(hex: "2ECC71")
    
    static let deepSaphire = Color(hex: "00324B")
    static let lightSaphire = Color(hex: "6F9ED6")
    static let darkDarkPurple = Color(hex: "1A0B2E")
    static let evenDarkerPurple = Color(hex: "0F051A")
    
    // Chat Bubble Color Palette - Vibrant Translucent Colors
    static let bubbleLight = Color(hex: "E0F0FF").opacity(0.15)      // Light sky blue, very translucent
    static let bubbleMedium = Color(hex: "E8E0FF").opacity(0.20)     // Light lavender, medium translucent
    static let bubbleWarm = Color(hex: "FFE8D0").opacity(0.08)       // Warm peach, translucent
    static let bubbleCool = Color(hex: "D0E8FF").opacity(0.16)       // Cool blue, translucent
    static let bubblePearl = Color(hex: "FFF0E0").opacity(0.14)      // Pearl cream, very subtle
    static let bubbleMist = Color(hex: "FFE0F0").opacity(0.15)       // Mist pink, very light
    static let bubbleFrost = Color(hex: "D0F0FF").opacity(0.32)      // Frost blue, minimal opacity
    static let bubbleSilver = Color(hex: "E0E0FF").opacity(0.12)     // Silver lavender, slightly more opaque

    // Helper for color interpolation
    static func lerp(from: Color, to: Color, fraction: CGFloat) -> Color {
        let fromComponents = from.components()
        let toComponents = to.components()
        let r = fromComponents.r + (toComponents.r - fromComponents.r) * fraction
        let g = fromComponents.g + (toComponents.g - fromComponents.g) * fraction
        let b = fromComponents.b + (toComponents.b - fromComponents.b) * fraction
        let a = fromComponents.a + (toComponents.a - fromComponents.a) * fraction
        return Color(red: r, green: g, blue: b, opacity: a)
    }
    // Extract RGBA components (works for sRGB colors)
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        #if canImport(UIKit)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
        #elseif canImport(AppKit)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        NSColor(self).usingColorSpace(.deviceRGB)?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
        #else
        return (0,0,0,1)
        #endif
    }
}
