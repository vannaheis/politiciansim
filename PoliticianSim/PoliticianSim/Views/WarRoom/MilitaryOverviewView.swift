//
//  MilitaryOverviewView.swift
//  PoliticianSim
//
//  Military overview and statistics
//

import SwiftUI

struct MilitaryOverviewView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let character = gameManager.character,
                   let militaryStats = character.militaryStats {

                    // Military Strength Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Military Strength")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Strength")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(militaryStats.strength)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Constants.Colors.positive)
                            }

                            Divider()
                                .background(Constants.Colors.secondaryText.opacity(0.3))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Manpower")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(militaryStats.manpower)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Recruitment Type Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recruitment")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack {
                            Text(militaryStats.recruitmentType.rawValue)
                                .font(.system(size: 15))
                                .foregroundColor(.white)

                            Spacer()

                            Text("Cost: \(formatMoney(militaryStats.recruitmentType.costPerSoldier))/soldier")
                                .font(.system(size: 13))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Military Budget Card
                    MilitaryBudgetCard(militaryStats: militaryStats)

                    // Military Treasury Card
                    MilitaryTreasuryCard(treasury: militaryStats.treasury)

                    // Nuclear Arsenal Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nuclear Arsenal")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        if militaryStats.nuclearArsenal.isNuclearPower {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Warheads:")
                                        .foregroundColor(Constants.Colors.secondaryText)
                                    Spacer()
                                    Text("\(militaryStats.nuclearArsenal.warheadCount)")
                                        .foregroundColor(.white)
                                }

                                HStack {
                                    Text("ICBMs:")
                                        .foregroundColor(Constants.Colors.secondaryText)
                                    Spacer()
                                    Text("\(militaryStats.nuclearArsenal.icbmCount)")
                                        .foregroundColor(.white)
                                }

                                if militaryStats.nuclearArsenal.hasFirstStrikeCapability {
                                    Text("✓ First Strike Capable")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.positive)
                                }

                                if militaryStats.nuclearArsenal.hasSecondStrikeCapability {
                                    Text("✓ Second Strike Capable (MAD)")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.positive)
                                }
                            }
                        } else {
                            Text("No nuclear weapons")
                                .font(.system(size: 14))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                } else {
                    Text("No military data available")
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}

// MARK: - Military Budget Card

struct MilitaryBudgetCard: View {
    @EnvironmentObject var gameManager: GameManager
    let militaryStats: MilitaryStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Military Budget")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Annual Budget")
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(formatMoney(militaryStats.militaryBudget))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Constants.Colors.positive)
                }

                Spacer()
            }

            Divider()
                .background(Color.white.opacity(0.2))

            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.buttonPrimary)

                Text("To adjust military budget, go to Budget → Military Department")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}

// MARK: - Military Treasury Card

struct MilitaryTreasuryCard: View {
    let treasury: MilitaryTreasury

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "banknote.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.money)

                Text("Military Treasury")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }

            Divider().background(Color.white.opacity(0.2))

            // Revenue
            TreasuryRow(
                label: "Daily Revenue",
                amount: treasury.dailyRevenue,
                icon: "arrow.down.circle.fill",
                color: Constants.Colors.positive
            )

            // Expenses breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Expenses")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                TreasuryRow(
                    label: "  Personnel",
                    amount: treasury.personnelCosts,
                    icon: "person.fill",
                    color: Constants.Colors.negative,
                    isSubitem: true
                )

                TreasuryRow(
                    label: "  Maintenance",
                    amount: treasury.maintenanceCosts,
                    icon: "wrench.fill",
                    color: Constants.Colors.negative,
                    isSubitem: true
                )

                if treasury.warCosts > 0 {
                    TreasuryRow(
                        label: "  War Operations",
                        amount: treasury.warCosts,
                        icon: "flag.fill",
                        color: Constants.Colors.negative,
                        isSubitem: true
                    )
                }

                if treasury.researchCosts > 0 {
                    TreasuryRow(
                        label: "  Research",
                        amount: treasury.researchCosts,
                        icon: "flame.fill",
                        color: Constants.Colors.negative,
                        isSubitem: true
                    )
                }

                TreasuryRow(
                    label: "Total Expenses",
                    amount: treasury.dailyExpenses,
                    icon: "arrow.up.circle.fill",
                    color: Constants.Colors.negative,
                    isBold: true
                )
            }

            Divider().background(Color.white.opacity(0.2))

            // Net Daily
            HStack {
                Image(systemName: treasury.isDeficit ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(treasury.isDeficit ? .orange : Constants.Colors.positive)

                Text("Net Daily:")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text(formatMoney(treasury.netDaily))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(treasury.isDeficit ? .orange : Constants.Colors.positive)
            }

            // Cash Reserves
            HStack {
                Text("Cash Reserves:")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text(formatMoney(treasury.cashReserves))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(treasury.cashReserves >= 0 ? .white : .orange)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(truncating: amount as NSNumber)
        if abs(value) >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if abs(value) >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if abs(value) >= 1_000 {
            return String(format: "$%.1fK", value / 1_000)
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}

struct TreasuryRow: View {
    let label: String
    let amount: Decimal
    let icon: String
    let color: Color
    var isSubitem: Bool = false
    var isBold: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isSubitem ? 10 : 12))
                .foregroundColor(color)
                .frame(width: 16)

            Text(label)
                .font(.system(size: isSubitem ? 12 : 13, weight: isBold ? .bold : .regular))
                .foregroundColor(isSubitem ? Constants.Colors.secondaryText : .white)

            Spacer()

            Text(formatMoney(amount))
                .font(.system(size: isSubitem ? 12 : 13, weight: isBold ? .bold : .semibold))
                .foregroundColor(color)
        }
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(truncating: amount as NSNumber)
        if abs(value) >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if abs(value) >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if abs(value) >= 1_000 {
            return String(format: "$%.1fK", value / 1_000)
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}

#Preview {
    MilitaryOverviewView()
        .environmentObject(GameManager.shared)
}
