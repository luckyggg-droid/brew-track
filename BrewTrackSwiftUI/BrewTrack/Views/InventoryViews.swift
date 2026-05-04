import SwiftUI

enum SortKey: String, CaseIterable, Identifiable {
    case name
    case status
    case quantityAscending
    case quantityDescending
    case owed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name: return "A-Z"
        case .status: return "By Status"
        case .quantityAscending: return "Qty Up"
        case .quantityDescending: return "Qty Down"
        case .owed: return "Most Owed"
        }
    }

}

enum StockFilter: String, CaseIterable, Identifiable {
    case all
    case out
    case low
    case ok

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .out: return "Out of Stock"
        case .low: return "Low Stock"
        case .ok: return "In Stock"
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var viewModel: InventoryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var search = ""
    @State private var sort: SortKey = .name
    @State private var filter: StockFilter = .all

    private var filteredItems: [InventoryItem] {
        var result = viewModel.loadedItems

        if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = search.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.supplier.lowercased().contains(query) ||
                $0.category.lowercased().contains(query)
            }
        }

        switch filter {
        case .all: break
        case .out: result = result.filter { $0.quantity == 0 }
        case .low: result = result.filter { $0.quantity > 0 && $0.status == .low }
        case .ok: result = result.filter { $0.status == .ok }
        }

        switch sort {
        case .name:
            result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .status:
            let order: [ItemStatus: Int] = [.out: 0, .low: 1, .ok: 2]
            result.sort { (order[$0.status] ?? 0) < (order[$1.status] ?? 0) }
        case .quantityAscending:
            result.sort { $0.quantity < $1.quantity }
        case .quantityDescending:
            result.sort { $0.quantity > $1.quantity }
        case .owed:
            result.sort { $0.amountOwed > $1.amountOwed }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 18) {
            InsightCard(title: "Smart Insights", rows: viewModel.insights())

            LazyVGrid(columns: statColumns, spacing: 16) {
                StatCard(value: "\(viewModel.loadedItems.count)", label: "Items", color: AppTheme.textDark)
                StatCard(value: "\(viewModel.loadedItems.filter { $0.status == .out }.count)", label: "Out", color: AppTheme.out)
                StatCard(value: "\(viewModel.loadedItems.filter { $0.status == .low }.count)", label: "Low", color: AppTheme.low)
                StatCard(value: MoneyFormatting.money(viewModel.loadedItems.reduce(0) { $0 + $1.amountOwed }, decimals: 0), label: "Owed", color: AppTheme.teacup)
            }

            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppTheme.textLight)
                    TextField("Search items, suppliers...", text: $search)
                        .textInputAutocapitalization(.never)
                }
                .font(AppFont.regular(18))
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
                .background(CardBackground(cornerRadius: 22))
                .frame(maxWidth: .infinity)

                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(SortKey.allCases) { key in
                            Text(key.title).tag(key)
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(sort.title)
                        Image(systemName: "chevron.down")
                    }
                    .font(AppFont.bold(24))
                    .foregroundStyle(AppTheme.textDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.95)
                    .padding(.horizontal, 46)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(CardBackground(cornerRadius: 22))
                }
            }

            ChipRow(items: StockFilter.allCases, selection: $filter) { $0.title }

            HStack {
                Text("\(filteredItems.count) item\(filteredItems.count == 1 ? "" : "s")")
                    .font(AppFont.bold(29))
                    .foregroundStyle(AppTheme.textLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.95)
                    .padding(.leading, 16)
                Spacer()
                Button {
                    viewModel.openAdd()
                } label: {
                    Label("Add Item", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
            }

            if filteredItems.isEmpty {
                EmptyState(
                    systemImage: "cup.and.saucer.fill",
                    title: search.isEmpty ? "No items here" : "No items match your search",
                    subtitle: search.isEmpty ? "Tap Add Item to get started" : "Try a different keyword"
                )
            } else {
                ForEach(filteredItems) { item in
                    ItemCard(item: item)
                }
            }
        }
    }

    private var statColumns: [GridItem] {
        if horizontalSizeClass == .compact {
            return Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
        }
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    }
}

struct ItemCard: View {
    @EnvironmentObject private var viewModel: InventoryViewModel
    let item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(AppFont.bold(34))
                        .foregroundStyle(AppTheme.textDark)
                        .lineLimit(2)
                        .minimumScaleFactor(0.95)
                    Text("\(item.supplier) - \(item.category)")
                        .font(AppFont.rounded(25, weight: .medium))
                        .foregroundStyle(AppTheme.textLight)
                        .lineLimit(3)
                }
                .layoutPriority(1)
                StatusPill(status: item.status, text: item.status == .low ? "Low: \(item.quantity)" : item.status.label)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(MoneyFormatting.money(item.amountOwed))
                    .font(AppFont.bold(30))
                    .foregroundStyle(AppTheme.teacupDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.95)

                VStack(spacing: 13) {
                    if item.amountOwed > 0 {
                        Button("Mark Paid") {
                            viewModel.markPaid(item: item)
                        }
                        .buttonStyle(SmallTeacupButtonStyle())
                    }

                    HStack(spacing: 12) {
                        Button("View") {
                            viewModel.openDetail(item)
                        }
                        .buttonStyle(OutlineMiniButtonStyle(color: AppTheme.teacup))

                        Button("Edit") {
                            viewModel.openEdit(item)
                        }
                        .buttonStyle(OutlineMiniButtonStyle())
                    }

                    Button("Delete") {
                        viewModel.delete(item)
                    }
                    .buttonStyle(OutlineMiniButtonStyle(color: AppTheme.out))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.card)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.statusColor(item.status))
                        .frame(width: 4)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
        )
    }
}

struct DetailView: View {
    @EnvironmentObject private var viewModel: InventoryViewModel
    let item: InventoryItem

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    viewModel.viewState = .list
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(OutlineMiniButtonStyle())
                Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.name)
                            .font(AppFont.bold(36))
                            .foregroundStyle(AppTheme.textDark)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                        StatusPill(status: item.status, text: item.status.detailLabel)
                    }
                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(item.quantity)")
                        .font(AppFont.bold(38))
                        .foregroundStyle(AppTheme.honeyDark)
                        .lineLimit(1)
                    Text("units")
                        .font(AppFont.bold(20))
                        .foregroundStyle(AppTheme.textLight)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(CardBackground(cornerRadius: 18, border: AppTheme.honeyLight))

            InfoCard(title: "Item Info") {
                InfoRow(label: "Category", value: item.category)
                InfoRow(label: "Supplier", value: item.supplier)
                InfoRow(label: "Min Stock Alert", value: "\(item.minStock) units")
            }

            InfoCard(title: "Supplier Debt", border: AppTheme.teacupLight, titleColor: AppTheme.teacup) {
                InfoRow(label: "Amount Owed", value: MoneyFormatting.money(item.amountOwed), valueColor: AppTheme.teacupDark)
            }

            VStack(spacing: 10) {
                Button {
                    viewModel.openEdit(item)
                } label: {
                    Label("Edit Item", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryRoundedButtonStyle())

                Button {
                    viewModel.delete(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DangerRoundedButtonStyle())
            }

            let entries = viewModel.history(for: item)
            if !entries.isEmpty {
                HStack {
                    Text("History for this item")
                        .font(AppFont.bold(18))
                        .foregroundStyle(AppTheme.textLight)
                    Spacer()
                }
                ForEach(entries) { entry in
                    HistoryEntryRow(entry: entry)
                }
            }
        }
    }

}

struct AlertsView: View {
    @EnvironmentObject private var viewModel: InventoryViewModel

    private var alerts: [InventoryItem] {
        viewModel.loadedItems
            .filter { $0.quantity < max($0.minStock, 1) }
            .sorted { $0.quantity < $1.quantity }
    }

    var body: some View {
        VStack(spacing: 12) {
            if alerts.isEmpty {
                EmptyState(systemImage: "checkmark.circle.fill", title: "No alerts", subtitle: "All stock levels are healthy")
            } else {
                InsightCard(
                    title: "Restock Recommendations",
                    rows: alerts.prefix(3).map { "\($0.name): \($0.quantity == 0 ? "Order ASAP" : "Order soon"). Min \($0.minStock), currently \($0.quantity)." }
                )

                ForEach(alerts) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.name)
                                    .font(AppFont.bold(30))
                                    .foregroundStyle(AppTheme.textDark)
                                    .lineLimit(2)
                                Text(item.supplier)
                                    .font(AppFont.rounded(23, weight: .medium))
                                    .foregroundStyle(AppTheme.textLight)
                            }
                            .layoutPriority(1)
                            StatusPill(status: item.status, text: item.status == .out ? "Out of Stock" : "Low: \(item.quantity) left")
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Min: \(item.minStock) units")
                                .font(AppFont.bold(24))
                                .foregroundStyle(AppTheme.textLight)
                            Button("Restock") {
                                viewModel.openEdit(item)
                            }
                            .buttonStyle(OutlineMiniButtonStyle(color: AppTheme.teacup))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(CardBackground(cornerRadius: 16))
                }
            }
        }
    }
}

struct SuppliersView: View {
    @EnvironmentObject private var viewModel: InventoryViewModel

    var body: some View {
        VStack(spacing: 10) {
            let suppliers = viewModel.supplierSummaries
            if suppliers.isEmpty {
                EmptyState(systemImage: "shippingbox.fill", title: "No suppliers yet", subtitle: nil)
            } else {
                HStack {
                    Text("\(suppliers.count) Suppliers")
                        .font(AppFont.bold(29))
                        .foregroundStyle(AppTheme.textLight)
                        .padding(.leading, 8)
                    Spacer()
                }

                ForEach(suppliers) { supplier in
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(supplier.name)
                                    .font(AppFont.bold(30))
                                    .foregroundStyle(AppTheme.textDark)
                                    .lineLimit(2)
                                Text("\(supplier.items.count) item\(supplier.items.count > 1 ? "s" : "")")
                                    .font(AppFont.rounded(23, weight: .medium))
                                    .foregroundStyle(AppTheme.textLight)
                                    .lineLimit(1)
                                Text("\(MoneyFormatting.money(supplier.owed, decimals: 0)) owed")
                                    .font(AppFont.bold(31))
                                    .foregroundStyle(AppTheme.teacupDark)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)
                                    .padding(.bottom, 15)
                                    .background(AppTheme.teacupLight)
                                    .clipShape(Capsule())
                            }
                            .layoutPriority(1)
                            if supplier.owed > 0 {
                                Button("Pay \(MoneyFormatting.money(supplier.owed, decimals: 0))") {
                                    viewModel.markPaid(supplier: supplier)
                                }
                                .buttonStyle(SmallTeacupButtonStyle())
                            }
                        }

                        FlowLayout(spacing: 6) {
                            ForEach(supplier.items, id: \.self) { name in
                                Text(name)
                                    .font(AppFont.bold(23))
                                    .foregroundStyle(AppTheme.textDark)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.latteLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(CardBackground(cornerRadius: 16))
                }
            }
        }
    }
}

enum HistoryFilter: String, CaseIterable, Identifiable {
    case all
    case restock
    case order
    case edit

    var id: String { rawValue }

    var title: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

struct HistoryView: View {
    @EnvironmentObject private var viewModel: InventoryViewModel
    @State private var filter: HistoryFilter = .all

    private var filtered: [HistoryEntry] {
        filter == .all ? viewModel.history : viewModel.history.filter { $0.type.rawValue == filter.rawValue }
    }

    var body: some View {
        VStack(spacing: 14) {
            if viewModel.history.isEmpty {
                EmptyState(systemImage: "list.clipboard.fill", title: "No history yet", subtitle: "Actions will appear here")
            } else {
                ChipRow(items: HistoryFilter.allCases, selection: $filter) { $0.title }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)

                if filtered.isEmpty {
                    EmptyState(systemImage: "tray.fill", title: "No \(filter.rawValue) records", subtitle: nil)
                } else {
                    ForEach(filtered) { entry in
                        HistoryEntryRow(entry: entry)
                            .padding(.horizontal, 12)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
