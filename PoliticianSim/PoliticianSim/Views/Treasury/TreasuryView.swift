//
//  TreasuryView.swift
//  PoliticianSim
//
//  Government treasury and debt management view
//

import SwiftUI

struct TreasuryView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header with menu button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.navigationManager.toggleMenu()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Treasury")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer to balance menu button
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if gameManager.treasuryManager.currentTreasury != nil {
                    TreasuryContentView()
                } else {
                    NoTreasuryView()
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .onAppear {
            // Initialize treasury if character has a position
            if gameManager.treasuryManager.currentTreasury == nil,
               let character = gameManager.character,
               character.currentPosition != nil {
                gameManager.treasuryManager.initializeTreasury(for: character)
            }
        }
    }
}

// MARK: - Treasury Content

struct TreasuryContentView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let summary = gameManager.treasuryManager.getTreasurySummary(gdp: getGDP()) {
                    // Current Balance Card
                    CurrentBalanceCard(summary: summary)

                    // Debt Statistics Card
                    DebtStatisticsCard(summary: summary)

                    // Recent History Card
                    RecentHistoryCard(summary: summary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
    }

    private func getGDP() -> Double? {
        guard let character = gameManager.character,
              let position = character.currentPosition else { return nil }

        switch position.level {
        case 1: return gameManager.economicDataManager.economicData.local.gdp.current
        case 2: return gameManager.economicDataManager.economicData.state.gdp.current
        case 3, 4, 5: return gameManager.economicDataManager.economicData.federal.gdp.current
        default: return nil
        }
    }
}

// MARK: - Current Balance Card

struct CurrentBalanceCard: View {
    let summary: TreasuryManager.TreasurySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 12))
                    .foregroundColor(summary.isInDebt ? Constants.Colors.negative : Constants.Colors.positive)

                Text("Current Position")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            VStack(spacing: 16) {
                // Main balance display
                VStack(spacing: 4) {
                    Text(summary.isInDebt ? "National Debt" : "Treasury Reserves")
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(formatMoney(abs(summary.currentBalance)))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(summary.isInDebt ? Constants.Colors.negative : Constants.Colors.positive)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Debt-to-GDP Ratio (if in debt)
                if summary.isInDebt, let debtToGDP = summary.debtToGDPRatio {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Debt-to-GDP Ratio")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text("\(String(format: "%.1f", debtToGDP))%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(getRatioColor(debtToGDP))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(getRatioLabel(debtToGDP))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(getRatioColor(debtToGDP))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(getRatioColor(debtToGDP).opacity(0.2))
                                )
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func getRatioColor(_ ratio: Double) -> Color {
        if ratio < 60 {
            return Constants.Colors.positive
        } else if ratio < 90 {
            return .orange
        } else {
            return Constants.Colors.negative
        }
    }

    private func getRatioLabel(_ ratio: Double) -> String {
        if ratio < 60 {
            return "SUSTAINABLE"
        } else if ratio < 90 {
            return "ELEVATED"
        } else {
            return "CRITICAL"
        }
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSDecimalNumber)
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000.0)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000.0)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000.0)
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

// MARK: - Debt Statistics Card

struct DebtStatisticsCard: View {
    let summary: TreasuryManager.TreasurySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cumulative Totals")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                TreasuryStatRow(
                    icon: "arrow.down.circle.fill",
                    iconColor: Constants.Colors.negative,
                    label: "Total Debt Accumulated",
                    value: formatMoney(summary.totalDebt)
                )

                TreasuryStatRow(
                    icon: "arrow.up.circle.fill",
                    iconColor: Constants.Colors.positive,
                    label: "Total Surplus Accumulated",
                    value: formatMoney(summary.totalSurplus)
                )

                if summary.isInDebt {
                    Divider()
                        .background(Color.white.opacity(0.2))

                    TreasuryStatRow(
                        icon: "percent",
                        iconColor: .orange,
                        label: "Interest Rate",
                        value: "\(String(format: "%.2f", summary.interestRate))%"
                    )

                    TreasuryStatRow(
                        icon: "calendar",
                        iconColor: .orange,
                        label: "Annual Interest Payment",
                        value: formatMoney(summary.annualInterestPayment)
                    )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSDecimalNumber)
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000.0)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000.0)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000.0)
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

struct TreasuryStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(iconColor)
            }

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Recent History Card

struct RecentHistoryCard: View {
    let summary: TreasuryManager.TreasurySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            if summary.recentEntries.isEmpty {
                Text("No transactions yet. Apply budgets to see treasury changes.")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 8) {
                    ForEach(summary.recentEntries) { entry in
                        TreasuryHistoryRow(entry: entry)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct TreasuryHistoryRow: View {
    let entry: TreasuryEntry

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: entry.cashChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(entry.cashChange >= 0 ? Constants.Colors.positive : Constants.Colors.negative)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)

                    Text("FY \(entry.fiscalYear) • \(formattedDate(entry.date))")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatChange(entry.cashChange))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(entry.cashChange >= 0 ? Constants.Colors.positive : Constants.Colors.negative)

                    Text(formatBalance(entry.endingBalance))
                        .font(.system(size: 10))
                        .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))
        }
    }

    private func formatChange(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSDecimalNumber)
        let prefix = value >= 0 ? "+" : ""
        if abs(value) >= 1_000_000_000_000 {
            return String(format: "%@$%.2fT", prefix, value / 1_000_000_000_000.0)
        } else if abs(value) >= 1_000_000_000 {
            return String(format: "%@$%.1fB", prefix, value / 1_000_000_000.0)
        } else if abs(value) >= 1_000_000 {
            return String(format: "%@$%.1fM", prefix, value / 1_000_000.0)
        } else {
            return String(format: "%@$%.0f", prefix, value)
        }
    }

    private func formatBalance(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSDecimalNumber)
        let label = value < 0 ? "Debt: " : "Reserves: "
        if abs(value) >= 1_000_000_000_000 {
            return String(format: "%@$%.2fT", label, abs(value) / 1_000_000_000_000.0)
        } else if abs(value) >= 1_000_000_000 {
            return String(format: "%@$%.1fB", label, abs(value) / 1_000_000_000.0)
        } else if abs(value) >= 1_000_000 {
            return String(format: "%@$%.1fM", label, abs(value) / 1_000_000.0)
        } else {
            return String(format: "%@$%.0f", label, abs(value))
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - No Treasury View

struct NoTreasuryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.3))

            VStack(spacing: 8) {
                Text("No Treasury Available")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("You need an official government position to manage the treasury.")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TreasuryView()
        .environmentObject(GameManager.shared)
}
