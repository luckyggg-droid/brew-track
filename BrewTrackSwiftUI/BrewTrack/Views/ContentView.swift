import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: InventoryViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            let compactPhone = horizontalSizeClass == .compact && proxy.size.width <= 430
            let cornerRadius: CGFloat = compactPhone ? 0 : 36
            let borderWidth: CGFloat = compactPhone ? 0 : 7

            ZStack(alignment: .bottom) {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    if viewModel.items == nil {
                        LoadingView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        tabBar

                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(spacing: 18) {
                                currentScreen
                            }
                            .padding(.horizontal, compactPhone ? 18 : 32)
                            .padding(.top, compactPhone ? 22 : 18)
                            .padding(.bottom, compactPhone ? 180 : 96)
                            .frame(maxWidth: .infinity, alignment: .top)
                            .contentShape(Rectangle())
                        }
                        .coordinateSpace(name: "mainInventoryScroll")
                        .scrollDisabled(false)
                        .scrollIndicators(.visible)
                        .scrollDismissesKeyboard(.interactively)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(
                    width: compactPhone ? proxy.size.width : min(proxy.size.width - 40, 620),
                    height: compactPhone ? proxy.size.height : max(proxy.size.height - 48, 0)
                )
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color(red: 0.16, green: 0.10, blue: 0.04), lineWidth: borderWidth)
                        .allowsHitTesting(false)
                )
                .shadow(color: Color.black.opacity(compactPhone ? 0 : 0.16), radius: 30, x: 0, y: 20)
                .padding(.horizontal, compactPhone ? 0 : 12)
                .padding(.vertical, compactPhone ? 0 : 24)

                if viewModel.showToast {
                    Text(viewModel.toastMessage)
                        .font(AppFont.bold(21))
                        .foregroundStyle(AppTheme.latteLight)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(AppTheme.textDark)
                        .clipShape(Capsule())
                        .padding(.bottom, compactPhone ? 18 : 36)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $viewModel.isShowingForm) {
            AddEditItemView(item: viewModel.editingItem)
                .presentationDetents([.large])
        }
        .font(AppFont.regular(19))
        .task {
            await viewModel.load()
        }
    }

    private var header: some View {
        let compactPhone = horizontalSizeClass == .compact

        return VStack(spacing: 0) {
            HStack {
                Text("9:41")
                Spacer()
                Text("100%")
            }
            .font(AppFont.bold(17))
            .foregroundStyle(AppTheme.textDark)
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 6)

            HStack(alignment: .center, spacing: compactPhone ? 8 : 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Brew & Track")
                        .font(AppFont.bold(compactPhone ? 38 : 36))
                        .foregroundStyle(AppTheme.textDark)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Cafe Manager")
                        .font(AppFont.bold(compactPhone ? 24 : 22))
                        .foregroundStyle(AppTheme.textLight)
                }
                .layoutPriority(1)

                Spacer()

                if let count = viewModel.items?.count {
                    if compactPhone {
                        EmptyView()
                    } else {
                        Text("\(count) items")
                            .font(AppFont.bold(22))
                            .foregroundStyle(AppTheme.honeyDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.95)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 11)
                            .background(AppTheme.honeyLight)
                            .clipShape(Capsule())
                    }
                }

                Button {
                    authViewModel.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.out)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.card)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(AppTheme.border, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, compactPhone ? 28 : 22)
            .padding(.bottom, compactPhone ? 10 : 16)

            if compactPhone, let count = viewModel.items?.count {
                HStack {
                    Text("\(count) items")
                        .font(AppFont.bold(24))
                        .foregroundStyle(AppTheme.honeyDark)
                        .lineLimit(1)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 11)
                        .background(AppTheme.honeyLight)
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 16)
            }
        }
        .background(AppTheme.latteLight)
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(InventoryTab.allCases) { tab in
                    Button {
                        viewModel.selectedTab = tab
                        viewModel.viewState = .list
                    } label: {
                        Text(tab.title)
                            .font(AppFont.bold(22))
                            .foregroundStyle(viewModel.selectedTab == tab ? AppTheme.honeyDark : AppTheme.textLight)
                            .lineLimit(1)
                            .minimumScaleFactor(0.95)
                            .frame(minWidth: 116)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(viewModel.selectedTab == tab ? AppTheme.card : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(viewModel.selectedTab == tab ? AppTheme.honeyLight : .clear, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(AppTheme.latteLight)
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch viewModel.selectedTab {
        case .home:
            switch viewModel.viewState {
            case .list:
                HomeView()
            case .detail(let item):
                DetailView(item: latest(item))
            }
        case .alerts:
            AlertsView()
        case .suppliers:
            SuppliersView()
        case .history:
            HistoryView()
        }
    }

    private func latest(_ item: InventoryItem) -> InventoryItem {
        viewModel.loadedItems.first(where: { $0.id == item.id }) ?? item
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(AppTheme.honey)
                .scaleEffect(1.2)
            Text("Loading inventory...")
                .font(AppFont.bold(21))
                .foregroundStyle(AppTheme.textLight)
        }
        .padding(.vertical, 80)
    }
}
