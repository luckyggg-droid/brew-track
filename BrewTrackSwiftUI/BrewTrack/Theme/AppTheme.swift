import SwiftUI

enum AppTheme {
    static let honey = Color(red: 0.84, green: 0.66, blue: 0.33)
    static let honeyLight = Color(red: 0.94, green: 0.85, blue: 0.66)
    static let honeyDark = Color(red: 0.63, green: 0.47, blue: 0.19)
    static let latteLight = Color(red: 0.96, green: 0.90, blue: 0.83)
    static let teacup = Color(red: 0.36, green: 0.51, blue: 0.60)
    static let teacupLight = Color(red: 0.72, green: 0.82, blue: 0.88)
    static let teacupDark = Color(red: 0.23, green: 0.37, blue: 0.46)
    static let background = Color(red: 0.98, green: 0.95, blue: 0.93)
    static let card = Color(red: 1.00, green: 0.98, blue: 0.96)
    static let textDark = Color(red: 0.24, green: 0.17, blue: 0.10)
    static let textMid = Color(red: 0.48, green: 0.36, blue: 0.26)
    static let textLight = Color(red: 0.66, green: 0.53, blue: 0.42)
    static let good = Color(red: 0.42, green: 0.67, blue: 0.42)
    static let low = honey
    static let out = Color(red: 0.77, green: 0.33, blue: 0.29)
    static let border = Color(red: 0.93, green: 0.85, blue: 0.75)

    static func statusColor(_ status: ItemStatus) -> Color {
        switch status {
        case .ok: return good
        case .low: return low
        case .out: return out
        }
    }
}

enum AppFont {
    private static let family = "PatrickHand-Regular"

    static func regular(_ size: CGFloat) -> Font {
        .custom(family, size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom(family, size: size).weight(.bold)
    }

    static func rounded(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .custom(family, size: size).weight(weight)
    }
}
