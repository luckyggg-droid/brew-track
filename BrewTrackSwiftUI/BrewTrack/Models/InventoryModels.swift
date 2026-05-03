import Foundation

enum InventoryTab: String, CaseIterable, Identifiable {
    case home
    case alerts
    case suppliers
    case history

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Inventory"
        case .alerts: return "Alerts"
        case .suppliers: return "Suppliers"
        case .history: return "History"
        }
    }
}

enum InventoryViewState {
    case list
    case detail(InventoryItem)
}

enum ItemStatus: String {
    case ok
    case low
    case out

    var label: String {
        switch self {
        case .ok: return "Good"
        case .low: return "Low"
        case .out: return "Out"
        }
    }

    var detailLabel: String {
        switch self {
        case .ok: return "Good Stock"
        case .low: return "Low Stock"
        case .out: return "Out of Stock"
        }
    }
}

enum HistoryType: String, CaseIterable, Identifiable {
    case restock
    case order
    case edit

    var id: String { rawValue }
    var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
}

struct InventoryItem: Identifiable, Equatable {
    var id: Int
    var name: String
    var quantity: Int
    var supplier: String
    var amountOwed: Double
    var category: String
    var minStock: Int

    var status: ItemStatus {
        if quantity == 0 { return .out }
        if quantity < max(minStock, 1) { return .low }
        return .ok
    }
}

struct HistoryEntry: Identifiable, Equatable {
    var id: Int
    var itemId: Int
    var itemName: String
    var type: HistoryType
    var quantity: Int
    var amount: Double
    var date: String
}

struct SupplierSummary: Identifiable {
    var id: String { name }
    var name: String
    var items: [String]
    var owed: Double
}

