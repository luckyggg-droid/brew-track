import SwiftUI

struct AddEditItemView: View {
    @EnvironmentObject private var viewModel: InventoryViewModel
    @Environment(\.dismiss) private var dismiss

    let item: InventoryItem?

    @State private var name: String
    @State private var quantity: Int
    @State private var supplier: String
    @State private var amount: String
    @State private var category: String
    @State private var minStock: Int
    @State private var errors: Set<FormField> = []

    enum FormField {
        case name
        case supplier
        case amount
    }

    init(item: InventoryItem?) {
        self.item = item
        _name = State(initialValue: item?.name ?? "")
        _quantity = State(initialValue: item?.quantity ?? 0)
        _supplier = State(initialValue: item?.supplier ?? "")
        _amount = State(initialValue: item.map { String($0.amountOwed) } ?? "")
        _category = State(initialValue: item?.category ?? "Dairy")
        _minStock = State(initialValue: item?.minStock ?? 5)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(item == nil ? "Add New Item" : "Edit Item")
                        .font(AppFont.bold(30))
                        .foregroundStyle(AppTheme.textDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 6)

                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(AppTheme.teacupDark)
                            .frame(width: 38, height: 38)
                            .background(AppTheme.card)
                            .clipShape(Circle())
                        Text("Fill in the details below and Brew & Track will keep your stock tidy.")
                            .font(AppFont.regular(18))
                            .foregroundStyle(AppTheme.teacupDark)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(AppTheme.teacupLight)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    FormTextField(title: "Item Name", placeholder: "e.g. Whole Milk", text: $name, hasError: errors.contains(.name))

                    HStack(spacing: 9) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Category")
                                .fieldLabel()
                            Picker("Category", selection: $category) {
                                ForEach(InventoryViewModel.categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .background(CardBackground(cornerRadius: 13))
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Min Stock Alert")
                                .fieldLabel()
                            Stepper("\(minStock)", value: $minStock, in: 1...999)
                                .font(AppFont.bold(18))
                                .foregroundStyle(AppTheme.textDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 11)
                                .background(CardBackground(cornerRadius: 13))
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quantity")
                            .fieldLabel()
                        HStack(spacing: 10) {
                            Button {
                                quantity = max(0, quantity - 1)
                            } label: {
                                Image(systemName: "minus")
                            }
                            .buttonStyle(QuantityButtonStyle())

                            Text("\(quantity)")
                                .font(AppFont.bold(24))
                                .foregroundStyle(AppTheme.textDark)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(minWidth: 54)

                            Button {
                                quantity += 1
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(QuantityButtonStyle())

                            Spacer()
                        }
                    }

                    FormTextField(title: "Supplier Name", placeholder: "e.g. FreshFarm Co.", text: $supplier, hasError: errors.contains(.supplier))

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 4) {
                            Text("Amount Owed (₹)")
                                .fieldLabel()
                            Text("optional")
                                .font(AppFont.regular(15))
                                .foregroundStyle(AppTheme.textLight)
                                .padding(.horizontal, 4)
                        }
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(InventoryTextFieldStyle(hasError: errors.contains(.amount)))
                        if errors.contains(.amount) {
                            Text("Enter valid amount")
                                .errorText()
                        }
                    }

                    HStack(spacing: 9) {
                        Button("Cancel") {
                            viewModel.isShowingForm = false
                            dismiss()
                        }
                        .buttonStyle(CancelRoundedButtonStyle())

                        Button(item == nil ? "Add Item" : "Save Changes") {
                            save()
                        }
                        .buttonStyle(PrimaryRoundedButtonStyle())
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
            }
            .background(AppTheme.background.ignoresSafeArea())
        }
    }

    private func save() {
        var nextErrors: Set<FormField> = []
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nextErrors.insert(.name)
        }
        if supplier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nextErrors.insert(.supplier)
        }
        let amountValue = Double(amount.isEmpty ? "0" : amount)
        if amountValue == nil || (amountValue ?? 0) < 0 {
            nextErrors.insert(.amount)
        }

        errors = nextErrors
        guard nextErrors.isEmpty else { return }

        let next = InventoryItem(
            id: item?.id ?? InventoryViewModel.genId(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            supplier: supplier.trimmingCharacters(in: .whitespacesAndNewlines),
            amountOwed: ((amountValue ?? 0) * 100).rounded() / 100,
            category: category,
            minStock: minStock
        )

        viewModel.save(next)
        dismiss()
    }
}

struct FormTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let hasError: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .fieldLabel()
            TextField(placeholder, text: $text)
                .textFieldStyle(InventoryTextFieldStyle(hasError: hasError))
            if hasError {
                Text("Required")
                    .errorText()
            }
        }
    }
}
