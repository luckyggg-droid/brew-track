import Foundation

enum MoneyFormatting {
    static func money(_ value: Double, decimals: Int = 2) -> String {
        "₹" + String(format: "%.\(decimals)f", value)
    }
}

enum DateFormatting {
    static func todayLabel() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: Date())
    }

    static func daysAgo(_ days: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

