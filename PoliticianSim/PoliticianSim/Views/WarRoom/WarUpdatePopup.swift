//
//  WarUpdatePopup.swift
//  PoliticianSim
//
//  Monthly war progress update popup
//

import SwiftUI

struct WarUpdatePopup: View {
    @EnvironmentObject var gameManager: GameManager
    let update: WarUpdate

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("WAR UPDATE")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(update.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(update.monthLabel)
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            Divider()
                .background(Color.white.opacity(0.2))

            // Content
            VStack(spacing: 20) {
                // Casualties
                VStack(alignment: .leading, spacing: 12) {
                    Text("CASUALTIES")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(update.war.attacker)
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text("\(formatNumber(update.attackerCasualties)) killed")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(update.war.defender)
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text("\(formatNumber(update.defenderCasualties)) killed")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // War costs
                VStack(alignment: .leading, spacing: 12) {
                    Text("WAR COSTS TO DATE")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(update.war.attacker)
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text(formatMoney(update.attackerCost))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(update.war.defender)
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text(formatMoney(update.defenderCost))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Attrition
                VStack(alignment: .leading, spacing: 12) {
                    Text("ATTRITION")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(update.war.attacker) Forces")
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text(String(format: "%.1f%% depleted", update.attackerAttritionPercent))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(update.war.defender) Forces")
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text(String(format: "%.1f%% depleted", update.defenderAttritionPercent))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Status
                VStack(alignment: .center, spacing: 8) {
                    Text("STATUS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(update.status)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(statusColor(for: update.statusColor))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(24)

            Divider()
                .background(Color.white.opacity(0.2))

            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    dismissUpdate()
                }) {
                    Text("Dismiss")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.25, green: 0.27, blue: 0.32))
                        .cornerRadius(8)
                }

                Button(action: {
                    // TODO: Navigate to war details
                    dismissUpdate()
                }) {
                    Text("War Details")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.buttonPrimary)
                        .cornerRadius(8)
                }
            }
            .padding(20)
        }
        .frame(width: 380)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private func dismissUpdate() {
        // Remove first update from pending list
        if !gameManager.pendingWarUpdates.isEmpty {
            gameManager.pendingWarUpdates.removeFirst()
        }
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 1

        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000_000))B"
        } else if value >= 1_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000))M"
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }

    private func statusColor(for colorName: String) -> Color {
        switch colorName {
        case "green": return Constants.Colors.positive
        case "red": return Constants.Colors.negative
        case "yellow": return Color.yellow
        default: return Color.white
        }
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "China",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 1_500_000,
        defenderStrength: 2_000_000,
        startDate: Date()
    )

    let update = WarUpdate(
        war: war,
        monthNumber: 3,
        totalWars: 2,
        warIndex: 0
    )

    return WarUpdatePopup(update: update)
        .environmentObject(GameManager.shared)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
}
