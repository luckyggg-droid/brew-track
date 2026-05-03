import Foundation

protocol InventoryInsightService {
    func generateInsights(for items: [InventoryItem]) -> [String]
}

struct RuleBasedInventoryInsightService: InventoryInsightService {
    func generateInsights(for items: [InventoryItem]) -> [String] {
        let out = items.filter { $0.quantity == 0 }
        let low = items.filter { $0.quantity > 0 && $0.quantity < max($0.minStock, 1) }
        let topOwed = items.filter { $0.amountOwed > 0 }.sorted { $0.amountOwed > $1.amountOwed }
        let totalOwed = items.reduce(0) { $0 + $1.amountOwed }
        var result: [String] = []

        if !out.isEmpty {
            let names = out.map(\.name).joined(separator: " & ")
            result.append("\(names) \(out.count > 1 ? "are" : "is") completely out. Order immediately.")
        }
        if !low.isEmpty {
            result.append("\(low.count) item\(low.count > 1 ? "s" : "") below minimum stock: \(low.map(\.name).joined(separator: ", ")).")
        }
        if let first = topOwed.first {
            result.append("Highest outstanding payment: \(MoneyFormatting.money(first.amountOwed, decimals: 0)) to \(first.supplier).")
        }
        if totalOwed > 200 {
            result.append("Total supplier debt is \(MoneyFormatting.money(totalOwed, decimals: 0)). Consider settling before month-end.")
        }
        if items.filter({ $0.category == "Dairy" && $0.quantity < 5 }).count > 1 {
            result.append("Multiple dairy items low. Consider a single bulk order to save delivery costs.")
        }

        return result.isEmpty ? ["All stock levels look healthy. Great job keeping things topped up!"] : result
    }
}

