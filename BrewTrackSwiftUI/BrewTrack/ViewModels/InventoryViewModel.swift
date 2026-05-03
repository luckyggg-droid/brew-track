import SwiftUI

@MainActor
final class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem]? = nil
    @Published var history: [HistoryEntry] = []
    @Published var selectedTab: InventoryTab = .home
    @Published var viewState: InventoryViewState = .list
    @Published var editingItem: InventoryItem? = nil
    @Published var isShowingForm = false
    @Published var toastMessage = ""
    @Published var showToast = false
    @Published var errorMessage: String? = nil

    static let categories = ["Dairy", "Beverages", "Syrups", "Dry Goods", "Packaging", "Other"]

    private let dataService: InventoryDataService
    private let insightService: InventoryInsightService

    init(
        dataService: InventoryDataService = FirestoreInventoryDataService(),
        insightService: InventoryInsightService = RuleBasedInventoryInsightService()
    ) {
        self.dataService = dataService
        self.insightService = insightService
    }

    var loadedItems: [InventoryItem] { items ?? [] }

    var supplierSummaries: [SupplierSummary] {
        var grouped: [String: SupplierSummary] = [:]
        loadedItems.forEach { item in
            var summary = grouped[item.supplier] ?? SupplierSummary(name: item.supplier, items: [], owed: 0)
            summary.items.append(item.name)
            summary.owed += item.amountOwed
            grouped[item.supplier] = summary
        }
        return grouped.values.sorted { $0.owed > $1.owed }
    }

    func load() async {
        errorMessage = nil

        if items == nil {
            items = LocalInventoryDataService.initialItems
            history = LocalInventoryDataService.initialHistory
        }

        do {
            async let nextItems = dataService.fetchInventory()
            async let nextHistory = dataService.fetchHistory()
            items = try await nextItems
            history = try await nextHistory
        } catch {
            errorMessage = "Showing starter inventory while Firebase catches up."
            showToast(errorMessage ?? "Something went wrong.")
        }
    }

    func openAdd() {
        editingItem = nil
        isShowingForm = true
    }

    func openEdit(_ item: InventoryItem) {
        editingItem = item
        viewState = .list
        isShowingForm = true
    }

    func openDetail(_ item: InventoryItem) {
        viewState = .detail(item)
    }

    func save(_ item: InventoryItem) {
        let historyEntry: HistoryEntry
        if let editingItem {
            items = loadedItems.map { $0.id == editingItem.id ? item : $0 }
            if case .detail(let selected) = viewState, selected.id == item.id {
                viewState = .detail(item)
            }
            historyEntry = addHistory(for: item, type: .edit)
            showToast("Item updated!")
        } else {
            items = loadedItems + [item]
            historyEntry = addHistory(for: item, type: .restock)
            showToast("Item added!")
        }

        editingItem = nil
        isShowingForm = false

        persist {
            try await self.dataService.saveInventoryItem(item)
            try await self.dataService.saveHistoryEntry(historyEntry)
        }
    }

    func delete(_ item: InventoryItem) {
        items = loadedItems.filter { $0.id != item.id }
        viewState = .list
        showToast("Item deleted!")

        persist {
            try await self.dataService.deleteInventoryItem(item)
        }
    }

    func markPaid(item: InventoryItem) {
        let updatedItems = loadedItems.map { current in
            current.id == item.id ? current.withAmountOwed(0) : current
        }
        items = updatedItems
        let updatedItem = updatedItems.first(where: { $0.id == item.id }) ?? item.withAmountOwed(0)
        if case .detail(let selected) = viewState, selected.id == item.id {
            viewState = .detail(updatedItem)
        }
        showToast("Payment marked!")

        persist {
            try await self.dataService.saveInventoryItem(updatedItem)
        }
    }

    func markPaid(supplier: SupplierSummary) {
        let updatedItems = loadedItems.map { current in
            current.supplier == supplier.name ? current.withAmountOwed(0) : current
        }
        items = updatedItems
        showToast("Payment marked!")

        persist {
            for item in updatedItems where item.supplier == supplier.name {
                try await self.dataService.saveInventoryItem(item)
            }
        }
    }

    func insights() -> [String] {
        insightService.generateInsights(for: loadedItems)
    }

    func history(for item: InventoryItem) -> [HistoryEntry] {
        history.filter { $0.itemId == item.id }
    }

    func showToast(_ message: String) {
        toastMessage = message
        withAnimation { showToast = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation { showToast = false }
        }
    }

    @discardableResult
    private func addHistory(for item: InventoryItem, type: HistoryType) -> HistoryEntry {
        let entry = HistoryEntry(
            id: Self.genId(),
            itemId: item.id,
            itemName: item.name,
            type: type,
            quantity: item.quantity,
            amount: item.amountOwed,
            date: DateFormatting.todayLabel()
        )
        history.insert(entry, at: 0)
        return entry
    }

    private func persist(_ operation: @escaping () async throws -> Void) {
        Task {
            do {
                try await operation()
            } catch {
                errorMessage = "Could not save changes. Please check your connection."
                showToast(errorMessage ?? "Could not save changes.")
            }
        }
    }

    static func genId() -> Int {
        Int(Date().timeIntervalSince1970 * 1000) + Int.random(in: 0...999)
    }
}

private extension InventoryItem {
    func withAmountOwed(_ amount: Double) -> InventoryItem {
        InventoryItem(
            id: id,
            name: name,
            quantity: quantity,
            supplier: supplier,
            amountOwed: amount,
            category: category,
            minStock: minStock
        )
    }
}
