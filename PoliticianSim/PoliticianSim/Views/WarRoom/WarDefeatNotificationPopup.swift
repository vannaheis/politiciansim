//
//  WarDefeatNotificationPopup.swift
//  PoliticianSim
//
//  Displays notification when player loses a war
//

import SwiftUI

struct WarDefeatNotificationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let notification: WarDefeatNotification

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Constants.Colors.negative)

                Text(notification.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(notification.subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Consequences
            VStack(spacing: 16) {
                Text("Political Consequences")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ConsequenceRow(
                    icon: "star.fill",
                    label: "Reputation",
                    value: "-\(notification.reputationLoss)",
                    color: Constants.Colors.negative
                )

                ConsequenceRow(
                    icon: "hand.thumbsup.fill",
                    label: "Approval Rating",
                    value: String(format: "-%.1f%%", notification.approvalLoss),
                    color: Constants.Colors.negative
                )

                ConsequenceRow(
                    icon: "exclamationmark.triangle.fill",
                    label: "Stress",
                    value: "+\(notification.stressGain)",
                    color: .orange
                )

                if let territory = notification.formattedTerritory {
                    ConsequenceRow(
                        icon: "map.fill",
                        label: "Territory Lost",
                        value: territory,
                        color: Constants.Colors.negative
                    )
                }

                if let reparations = notification.formattedReparations {
                    ConsequenceRow(
                        icon: "dollarsign.circle.fill",
                        label: "Reparations Owed",
                        value: reparations,
                        color: Constants.Colors.negative
                    )
                }
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Peace Terms
            VStack(spacing: 8) {
                Text("Peace Terms Imposed")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(notification.peaceTerm.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)

            // Warning message
            Text("You may continue governing, but your political position is severely weakened. Impeachment is possible if approval drops too low.")
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 16)

            // Acknowledge button
            Button(action: dismissNotification) {
                Text("Acknowledge Defeat")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(Constants.Colors.negative)
            .cornerRadius(8)
            .padding(16)
        }
        .frame(width: 420)
        .frame(maxHeight: 550)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private func dismissNotification() {
        gameManager.pendingWarDefeatNotification = nil
    }
}

struct ConsequenceRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WarDefeatNotificationPopup(
        notification: WarDefeatNotification(
            war: War(
                attacker: "USA",
                defender: "CHN",
                type: .offensive,
                justification: .territorialDispute,
                attackerStrength: 1_000_000,
                defenderStrength: 1_500_000,
                startDate: Date()
            ),
            enemyName: "China",
            peaceTerm: .partialTerritory,
            territoryLost: 500_000,
            reparationAmount: 100_000_000_000,
            reputationLoss: 30,
            approvalLoss: 20.0,
            stressGain: 15
        )
    )
    .environmentObject(GameManager.shared)
}
