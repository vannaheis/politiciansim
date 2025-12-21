//
//  AIWarNotificationPopup.swift
//  PoliticianSim
//
//  Notification popup for AI war conclusions
//

import SwiftUI

struct AIWarNotificationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let notification: AIWarNotification

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)

                Text(notification.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(notification.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            Divider()
                .background(Color.white.opacity(0.2))

            // War Details
            ScrollView {
                VStack(spacing: 16) {
                    // Combatants
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("VICTOR")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(notification.winnerName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Constants.Colors.positive)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("DEFEATED")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(notification.loserName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Constants.Colors.negative)
                        }
                    }

                    Divider()
                        .background(Color.white.opacity(0.2))

                    // Casualties
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CASUALTIES")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text("\(formatNumber(abs(notification.war.casualtiesByCountry[notification.war.attacker] ?? 0))) \(notification.war.attacker)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text("\(formatNumber(abs(notification.war.casualtiesByCountry[notification.war.defender] ?? 0))) \(notification.war.defender)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("WAR COSTS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(formatMoney(notification.war.costByCountry[notification.war.attacker] ?? 0))
                                .font(.system(size: 13))
                                .foregroundColor(.white)

                            Text(formatMoney(notification.war.costByCountry[notification.war.defender] ?? 0))
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
                    }

                    Divider()
                        .background(Color.white.opacity(0.2))

                    // Peace Terms
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PEACE TERMS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text(notification.peaceTerm.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()
                        }

                        if let territoryFormatted = notification.formattedTerritory {
                            HStack(spacing: 6) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("Territory: \(territoryFormatted) (\(String(format: "%.0f%%", notification.territoryPercent * 100)))")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                        }

                        if let reparationsFormatted = notification.formattedReparations {
                            HStack(spacing: 6) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("Reparations: \(reparationsFormatted) over 10 years")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(24)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Dismiss Button
            Button(action: {
                dismissNotification()
            }) {
                Text("Acknowledge")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(Constants.Colors.accent)
            .cornerRadius(8)
            .padding(16)
        }
        .frame(width: 420)
        .frame(maxHeight: 500)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private func dismissNotification() {
        if !gameManager.pendingAIWarNotifications.isEmpty {
            gameManager.pendingAIWarNotifications.removeFirst()
        }
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000_000))B"
        } else if value >= 1_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000))M"
        } else {
            return "$\(String(format: "%.0f", value))"
        }
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "Cuba",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 1_390_000,
        defenderStrength: 50_000,
        startDate: Date()
    )

    let notification = AIWarNotification(
        war: war,
        winnerName: "United States",
        loserName: "Cuba",
        peaceTerm: .partialTerritory,
        territoryTransferred: 15_000,
        reparationAmount: 5_000_000_000
    )

    return ZStack {
        Color.black.opacity(0.7)
            .ignoresSafeArea()

        AIWarNotificationPopup(notification: notification)
    }
    .environmentObject(GameManager.shared)
}
