import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol InventoryDataService {
    func fetchInventory() async throws -> [InventoryItem]
    func fetchHistory() async throws -> [HistoryEntry]
    func saveInventoryItem(_ item: InventoryItem) async throws
    func deleteInventoryItem(_ item: InventoryItem) async throws
    func saveHistoryEntry(_ entry: HistoryEntry) async throws
}

struct LocalInventoryDataService: InventoryDataService {
    func fetchInventory() async throws -> [InventoryItem] {
        Self.initialItems
    }

    func fetchHistory() async throws -> [HistoryEntry] {
        Self.initialHistory
    }

    func saveInventoryItem(_ item: InventoryItem) async throws {}

    func deleteInventoryItem(_ item: InventoryItem) async throws {}

    func saveHistoryEntry(_ entry: HistoryEntry) async throws {}
}

struct FirestoreInventoryDataService: InventoryDataService {
    private let database = Firestore.firestore()

    func fetchInventory() async throws -> [InventoryItem] {
        let snapshot = try await inventoryCollection().getDocuments()
        let items = snapshot.documents.compactMap(Self.makeItem)

        if items.isEmpty {
            try await seedInitialData()
            return LocalInventoryDataService.initialItems
        }

        return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func fetchHistory() async throws -> [HistoryEntry] {
        let snapshot = try await historyCollection()
            .order(by: "sortId", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap(Self.makeHistoryEntry)
    }

    func saveInventoryItem(_ item: InventoryItem) async throws {
        try await inventoryCollection()
            .document(String(item.id))
            .setData(Self.data(for: item), merge: true)
    }

    func deleteInventoryItem(_ item: InventoryItem) async throws {
        try await inventoryCollection()
            .document(String(item.id))
            .delete()
    }

    func saveHistoryEntry(_ entry: HistoryEntry) async throws {
        try await historyCollection()
            .document(String(entry.id))
            .setData(Self.data(for: entry), merge: true)
    }

    private func seedInitialData() async throws {
        let batch = database.batch()
        let inventory = try inventoryCollection()
        let history = try historyCollection()

        LocalInventoryDataService.initialItems.forEach { item in
            batch.setData(Self.data(for: item), forDocument: inventory.document(String(item.id)), merge: true)
        }

        LocalInventoryDataService.initialHistory.forEach { entry in
            batch.setData(Self.data(for: entry), forDocument: history.document(String(entry.id)), merge: true)
        }

        try await batch.commit()
    }

    private func inventoryCollection() throws -> CollectionReference {
        try userDocument().collection("inventory")
    }

    private func historyCollection() throws -> CollectionReference {
        try userDocument().collection("history")
    }

    private func userDocument() throws -> DocumentReference {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw InventoryDataError.notSignedIn
        }
        return database.collection("users").document(uid)
    }

    private static func data(for item: InventoryItem) -> [String: Any] {
        [
            "id": item.id,
            "name": item.name,
            "quantity": item.quantity,
            "supplier": item.supplier,
            "amountOwed": item.amountOwed,
            "category": item.category,
            "minStock": item.minStock
        ]
    }

    private static func data(for entry: HistoryEntry) -> [String: Any] {
        [
            "id": entry.id,
            "sortId": entry.id,
            "itemId": entry.itemId,
            "itemName": entry.itemName,
            "type": entry.type.rawValue,
            "quantity": entry.quantity,
            "amount": entry.amount,
            "date": entry.date
        ]
    }

    private static func makeItem(from document: QueryDocumentSnapshot) -> InventoryItem? {
        let data = document.data()
        guard
            let name = data["name"] as? String,
            let supplier = data["supplier"] as? String,
            let category = data["category"] as? String
        else { return nil }

        return InventoryItem(
            id: intValue(data["id"]) ?? Int(document.documentID) ?? genId(),
            name: name,
            quantity: intValue(data["quantity"]) ?? 0,
            supplier: supplier,
            amountOwed: doubleValue(data["amountOwed"]) ?? 0,
            category: category,
            minStock: intValue(data["minStock"]) ?? 1
        )
    }

    private static func makeHistoryEntry(from document: QueryDocumentSnapshot) -> HistoryEntry? {
        let data = document.data()
        guard
            let itemName = data["itemName"] as? String,
            let typeRawValue = data["type"] as? String,
            let type = HistoryType(rawValue: typeRawValue),
            let date = data["date"] as? String
        else { return nil }

        return HistoryEntry(
            id: intValue(data["id"]) ?? Int(document.documentID) ?? genId(),
            itemId: intValue(data["itemId"]) ?? 0,
            itemName: itemName,
            type: type,
            quantity: intValue(data["quantity"]) ?? 0,
            amount: doubleValue(data["amount"]) ?? 0,
            date: date
        )
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let value = value as? Int { return value }
        if let value = value as? NSNumber { return value.intValue }
        return nil
    }

    private static func doubleValue(_ value: Any?) -> Double? {
        if let value = value as? Double { return value }
        if let value = value as? NSNumber { return value.doubleValue }
        return nil
    }

    private static func genId() -> Int {
        Int(Date().timeIntervalSince1970 * 1000) + Int.random(in: 0...999)
    }
}

enum InventoryDataError: LocalizedError {
    case notSignedIn

    var errorDescription: String? {
        "Please sign in before loading inventory."
    }
}

extension LocalInventoryDataService {
    static let initialItems: [InventoryItem] = [
        InventoryItem(id: 1, name: "Whole Milk", quantity: 3, supplier: "FreshFarm Co.", amountOwed: 45.0, category: "Dairy", minStock: 10),
        InventoryItem(id: 2, name: "Espresso Beans", quantity: 12, supplier: "Origin Roasters", amountOwed: 180.0, category: "Beverages", minStock: 8),
        InventoryItem(id: 3, name: "Oat Milk", quantity: 0, supplier: "Oatly Direct", amountOwed: 62.5, category: "Dairy", minStock: 6),
        InventoryItem(id: 4, name: "Vanilla Syrup", quantity: 2, supplier: "Monin Supplies", amountOwed: 28.0, category: "Syrups", minStock: 4),
        InventoryItem(id: 5, name: "Cups 8oz", quantity: 200, supplier: "PackRight", amountOwed: 0, category: "Packaging", minStock: 50),
        InventoryItem(id: 6, name: "Brown Sugar", quantity: 4, supplier: "SweetCo", amountOwed: 12.0, category: "Dry Goods", minStock: 10)
    ]

    static let initialHistory: [HistoryEntry] = [
        HistoryEntry(id: 101, itemId: 2, itemName: "Espresso Beans", type: .restock, quantity: 10, amount: 150, date: DateFormatting.daysAgo(1)),
        HistoryEntry(id: 102, itemId: 1, itemName: "Whole Milk", type: .order, quantity: 20, amount: 90, date: DateFormatting.daysAgo(2)),
        HistoryEntry(id: 103, itemId: 3, itemName: "Oat Milk", type: .restock, quantity: 12, amount: 125, date: DateFormatting.daysAgo(3)),
        HistoryEntry(id: 104, itemId: 4, itemName: "Vanilla Syrup", type: .order, quantity: 5, amount: 70, date: DateFormatting.daysAgo(5)),
        HistoryEntry(id: 105, itemId: 6, itemName: "Brown Sugar", type: .edit, quantity: 4, amount: 12, date: DateFormatting.daysAgo(7))
    ]
}
