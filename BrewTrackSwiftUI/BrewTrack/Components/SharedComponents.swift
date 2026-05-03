import SwiftUI

struct CardBackground: View {
    var cornerRadius: CGFloat = 14
    var border: Color = AppTheme.border

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(border, lineWidth: 1.5)
            )
    }
}

struct InsightCard: View {
    let title: String
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(AppTheme.teacup)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(AppFont.bold(27))
                    .foregroundStyle(AppTheme.teacup)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(AppTheme.honey)
                        .frame(width: 5, height: 5)
                        .padding(.top, 7)
                    Text(row)
                        .font(AppFont.rounded(23, weight: .medium))
                        .foregroundStyle(AppTheme.textDark)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if index != rows.count - 1 {
                    Divider()
                        .background(AppTheme.border)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .background(CardBackground(cornerRadius: 18, border: AppTheme.honeyLight))
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(AppFont.rounded(value.count > 4 ? 32 : 42, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Text(label)
                .font(AppFont.rounded(28, weight: .bold))
                .foregroundStyle(AppTheme.textLight)
                .lineLimit(1)
                .minimumScaleFactor(0.88)
        }
        .frame(maxWidth: .infinity, minHeight: 134)
        .padding(.vertical, 24)
        .padding(.horizontal, 18)
        .background(CardBackground(cornerRadius: 14, border: AppTheme.honeyLight))
    }
}

struct StatusPill: View {
    let status: ItemStatus
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.rounded(23, weight: .bold))
            .foregroundStyle(foreground)
            .lineLimit(1)
            .minimumScaleFactor(0.95)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(background)
            .clipShape(Capsule())
    }

    private var foreground: Color {
        switch status {
        case .ok: return Color(red: 0.18, green: 0.49, blue: 0.20)
        case .low: return Color(red: 0.52, green: 0.39, blue: 0.02)
        case .out: return Color(red: 0.52, green: 0.13, blue: 0.16)
        }
    }

    private var background: Color {
        switch status {
        case .ok: return Color(red: 0.83, green: 0.93, blue: 0.85)
        case .low: return Color(red: 1.00, green: 0.95, blue: 0.80)
        case .out: return Color(red: 0.97, green: 0.84, blue: 0.85)
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    var border: Color = AppTheme.border
    var titleColor: Color = AppTheme.textLight
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.bold(24))
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            content
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(CardBackground(cornerRadius: 16, border: border))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = AppTheme.textDark

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFont.rounded(20, weight: .bold))
                .foregroundStyle(AppTheme.textLight)
                .lineLimit(2)
            Text(value)
                .font(AppFont.rounded(24, weight: .semibold))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .minimumScaleFactor(0.95)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Divider()
                .background(AppTheme.border)
        }
    }
}

struct HistoryEntryRow: View {
    let entry: HistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.itemName)
                    .font(AppFont.bold(27))
                    .foregroundStyle(AppTheme.textDark)
                    .lineLimit(2)
                Text(entry.date)
                    .font(AppFont.regular(21))
                    .foregroundStyle(AppTheme.textLight)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(entry.quantity) units")
                    .font(AppFont.bold(24))
                    .foregroundStyle(AppTheme.textMid)
                Text(MoneyFormatting.money(entry.amount, decimals: 0))
                    .font(AppFont.bold(32))
                    .foregroundStyle(AppTheme.teacupDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
                    .background(AppTheme.teacupLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(entry.type.rawValue.uppercased())
                    .font(AppFont.bold(22))
                    .foregroundStyle(historyForeground(entry.type))
                    .lineLimit(1)
                    .padding(.horizontal, 16)
                    .padding(.top, 9)
                    .padding(.bottom, 12)
                    .background(historyBackground(entry.type))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 38)
        .padding(.vertical, 24)
        .background(CardBackground(cornerRadius: 14))
    }

    private func historyForeground(_ type: HistoryType) -> Color {
        switch type {
        case .restock: return Color(red: 0.18, green: 0.49, blue: 0.20)
        case .order: return Color(red: 0.12, green: 0.31, blue: 0.54)
        case .edit: return Color(red: 0.52, green: 0.39, blue: 0.02)
        }
    }

    private func historyBackground(_ type: HistoryType) -> Color {
        switch type {
        case .restock: return Color(red: 0.83, green: 0.93, blue: 0.85)
        case .order: return Color(red: 0.86, green: 0.91, blue: 0.96)
        case .edit: return Color(red: 1.00, green: 0.95, blue: 0.80)
        }
    }
}

struct EmptyState: View {
    let systemImage: String
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 42))
                .foregroundStyle(AppTheme.honey)
            Text(title)
                .font(AppFont.bold(21))
                .foregroundStyle(AppTheme.textMid)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
            if let subtitle {
                Text(subtitle)
                    .font(AppFont.regular(23))
                    .foregroundStyle(AppTheme.textLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

struct ChipRow<Item: Identifiable & Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    let title: (Item) -> String

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(items) { item in
                Button {
                    selection = item
                } label: {
                    Text(title(item))
                        .font(AppFont.bold(24))
                        .foregroundStyle(selection == item ? .white : AppTheme.textLight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .padding(.horizontal, 25)
                        .padding(.top, 15)
                        .padding(.bottom, 17)
                        .background(selection == item ? AppTheme.honey : AppTheme.card)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selection == item ? AppTheme.honey : AppTheme.border, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct PrimaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.bold(23))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .padding(.horizontal, 28)
            .padding(.top, 15)
            .padding(.bottom, 17)
            .background(AppTheme.honey.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(Capsule())
    }
}

struct PrimaryRoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.bold(20))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.95)
            .padding(.vertical, 15)
            .padding(.horizontal, 22)
            .background(AppTheme.honey.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct DangerRoundedButtonStyle: ButtonStyle {
    var color: Color = AppTheme.out

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.bold(20))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.95)
            .padding(.vertical, 15)
            .padding(.horizontal, 22)
            .background(CardBackground(cornerRadius: 14))
    }
}

struct CancelRoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.bold(20))
            .foregroundStyle(AppTheme.textMid)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .background(CardBackground(cornerRadius: 14))
    }
}

struct SmallTeacupButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.bold(24))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .padding(.horizontal, 28)
            .padding(.top, 20)
            .padding(.bottom, 23)
            .background(AppTheme.teacup.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(Capsule())
    }
}

struct OutlineMiniButtonStyle: ButtonStyle {
    var color: Color = AppTheme.textMid

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.bold(24))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 23)
            .background(CardBackground(cornerRadius: 12, border: color.opacity(configuration.isPressed ? 0.9 : 0.25)))
    }
}

struct QuantityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.bold(20))
            .foregroundStyle(AppTheme.textDark)
            .frame(width: 48, height: 40)
            .background(AppTheme.latteLight.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1.5)
            )
    }
}

struct InventoryTextFieldStyle: TextFieldStyle {
    var hasError = false

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppFont.regular(22))
            .foregroundStyle(AppTheme.textDark)
            .padding(.horizontal, 24)
            .padding(.top, 19)
            .padding(.bottom, 22)
            .background(CardBackground(cornerRadius: 13, border: hasError ? AppTheme.out : AppTheme.border))
    }
}

extension Text {
    func fieldLabel() -> some View {
        self
            .font(AppFont.bold(23))
            .foregroundStyle(AppTheme.textMid)
            .padding(.bottom, 2)
    }

    func errorText() -> some View {
        self
            .font(AppFont.bold(21))
            .foregroundStyle(AppTheme.out)
    }
}
