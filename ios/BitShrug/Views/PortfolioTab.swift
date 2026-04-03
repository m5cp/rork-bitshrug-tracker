import SwiftUI

struct PortfolioTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var portfolio = PortfolioManager.shared
    @State private var isEditing: Bool = false
    @State private var showPriceAlerts: Bool = false
    @State private var showFunWithNumbers: Bool = false

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if portfolio.btcHoldings > 0 {
                        holdingsHero
                        if portfolio.hasCostBasis {
                            plCard
                        }
                        statsGrid
                    } else {
                        emptyState
                    }

                    toolsSection
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(portfolio.btcHoldings > 0 ? "Edit" : "Add") {
                        isEditing = true
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $isEditing) {
                EditHoldingsSheet(portfolio: portfolio, currentPrice: viewModel.price)
            }
            .sheet(isPresented: $showPriceAlerts) {
                PriceAlertsView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showFunWithNumbers) {
                FunWithNumbersView(viewModel: viewModel)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)

            Image(systemName: "bitcoinsign.circle")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            Text("Track Your Holdings")
                .font(.title3)
                .fontWeight(.bold)

            Text("Add your Bitcoin holdings to\ntrack value and P&L over time.")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Button {
                isEditing = true
            } label: {
                Text("Add Holdings")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 200)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.top, 8)

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }

    private var holdingsHero: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HOLDINGS")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.primary)
                        .tracking(1.5)

                    Text(formatUSD(portfolio.currentValue(at: viewModel.price)))
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatBTC(portfolio.btcHoldings))
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundStyle(.orange)

                    Text("BTC")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.primary)
                        .tracking(1)
                }
            }

            HStack(spacing: 12) {
                metricPill(label: "Price", value: viewModel.formattedPrice)
                metricPill(label: "24h", value: viewModel.formattedChange)
                Spacer()
            }

            if let updated = viewModel.lastUpdated {
                Text("Price updated \(updated.formatted(.relative(presentation: .named)))")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.5))
            }
        }
        .premiumCard(.accent)
    }

    private var plCard: some View {
        let pl = portfolio.unrealizedPL(at: viewModel.price)
        let plPct = portfolio.plPercent(at: viewModel.price)
        let isPositive = pl >= 0

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "chart.line.uptrend.xyaxis", title: "PROFIT & LOSS")

            HStack(alignment: .firstTextBaseline) {
                Text("\(isPositive ? "+" : "")\(formatUSD(pl))")
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundStyle(AppColors.changeColor(positive: isPositive))

                Text("\(isPositive ? "+" : "")\(String(format: "%.1f", plPct))%")
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .foregroundStyle(AppColors.changeColor(positive: isPositive))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.changeColor(positive: isPositive).opacity(0.12))
                    .clipShape(Capsule())

                Spacer()
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cost Basis")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(formatUSD(portfolio.costBasis))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Invested")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(formatUSD(portfolio.totalCost()))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.primary)
                }

                Spacer()
            }
        }
        .premiumCard(.highlighted)
    }

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "number", title: "QUICK STATS")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statCell(
                    icon: "atom",
                    label: "Satoshis",
                    value: portfolio.satoshis().formatted(.number)
                )

                statCell(
                    icon: "chart.pie",
                    label: "% of Max Supply",
                    value: String(format: "%.6f%%", portfolio.percentOfMaxSupply())
                )

                if viewModel.powerLawSupport > 0 {
                    statCell(
                        icon: "arrow.down.to.line",
                        label: "At PL Support",
                        value: formatUSD(portfolio.btcHoldings * viewModel.powerLawSupport)
                    )
                }

                if viewModel.powerLawResistance > 0 {
                    statCell(
                        icon: "arrow.up.to.line",
                        label: "At PL Resistance",
                        value: formatUSD(portfolio.btcHoldings * viewModel.powerLawResistance)
                    )
                }
            }
        }
        .premiumCard()
    }

    private func statCell(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.orange)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Text(value)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.primary.opacity(0.04))
        .clipShape(.rect(cornerRadius: 10))
    }

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "wrench.and.screwdriver", title: "TOOLS")

            Button {
                showPriceAlerts = true
            } label: {
                toolRow(
                    icon: "bell.badge.fill",
                    iconColor: .orange,
                    title: "Price Alerts",
                    subtitle: "Custom targets & Power Law alerts"
                )
            }
            .buttonStyle(.plain)

            Button {
                showFunWithNumbers = true
            } label: {
                toolRow(
                    icon: "sparkles",
                    iconColor: .purple,
                    title: "Fun with Numbers",
                    subtitle: "Explore future Power Law projections"
                )
            }
            .buttonStyle(.plain)
        }
        .premiumCard()
    }

    private func toolRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }

    private func metricPill(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.primary.opacity(0.5))
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        }
    }

    private func formatUSD(_ value: Double) -> String {
        if abs(value) >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        } else if abs(value) >= 1_000 {
            return "$\(Int(value).formatted(.number))"
        }
        return String(format: "$%.2f", value)
    }

    private func formatBTC(_ value: Double) -> String {
        if value >= 1 {
            return String(format: "%.4f", value)
        } else if value >= 0.01 {
            return String(format: "%.6f", value)
        }
        return String(format: "%.8f", value)
    }
}

struct EditHoldingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let portfolio: PortfolioManager
    let currentPrice: Double

    @State private var btcText: String = ""
    @State private var costBasisText: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("BTC Amount")
                            .font(.subheadline)
                        Spacer()
                        TextField("0.00", text: $btcText)
                            .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Holdings")
                } footer: {
                    if let btc = Double(btcText), btc > 0, currentPrice > 0 {
                        Text("≈ $\(Int(btc * currentPrice).formatted(.number)) at current price")
                    }
                }

                Section {
                    HStack {
                        Text("Avg. Buy Price")
                            .font(.subheadline)
                        Spacer()
                        TextField("Optional", text: $costBasisText)
                            .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Cost Basis (USD)")
                } footer: {
                    Text("Enter your average purchase price to track P&L. This is optional.")
                }

                if portfolio.btcHoldings > 0 {
                    Section {
                        Button("Clear Holdings", role: .destructive) {
                            portfolio.clear()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Edit Holdings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let btc = Double(btcText) {
                            portfolio.btcHoldings = max(0, btc)
                        }
                        if let cost = Double(costBasisText), cost > 0 {
                            portfolio.costBasis = cost
                        } else if costBasisText.isEmpty {
                            portfolio.costBasis = 0
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(Double(btcText) == nil || (Double(btcText) ?? 0) <= 0)
                }
            }
            .onAppear {
                if portfolio.btcHoldings > 0 {
                    btcText = formatEditValue(portfolio.btcHoldings)
                }
                if portfolio.costBasis > 0 {
                    costBasisText = String(Int(portfolio.costBasis))
                }
            }
        }
    }

    private func formatEditValue(_ value: Double) -> String {
        if value == Double(Int(value)) {
            return String(Int(value))
        }
        return String(value)
    }
}
