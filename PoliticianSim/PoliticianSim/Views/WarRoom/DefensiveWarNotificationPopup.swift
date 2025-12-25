//
//  DefensiveWarNotificationPopup.swift
//  PoliticianSim
//
//  Displays notification when AI declares war on player
//

import SwiftUI

struct DefensiveWarNotificationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let notification: DefensiveWarNotification

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)

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

            // War Details
            VStack(spacing: 16) {
                Text("War Declaration")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Aggressor
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AGGRESSOR")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(notification.aggressorName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("STRENGTH")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(notification.formattedAggressorStrength)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Constants.Colors.negative)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)

                // Player
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("YOUR FORCES")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("United States")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("STRENGTH")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(notification.formattedPlayerStrength)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Constants.Colors.accent)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)

                // Threat Assessment
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(
                            red: notification.threatColor.red,
                            green: notification.threatColor.green,
                            blue: notification.threatColor.blue
                        ))

                    Text("Threat Level: \(notification.threatLevel)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(
                            red: notification.threatColor.red,
                            green: notification.threatColor.green,
                            blue: notification.threatColor.blue
                        ))

                    Spacer()

                    Text("Ratio: \(String(format: "%.2f", notification.strengthRatio)):1")
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Justification
            VStack(spacing: 8) {
                Text("Justification")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(notification.justification.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)

            // Information message
            Text("The war has begun. You can monitor progress in the War Room and negotiate peace terms when strategic objectives are met.")
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 16)

            // Acknowledge button
            Button(action: dismissNotification) {
                Text("To the War Room")
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
        .frame(maxHeight: 600)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private func dismissNotification() {
        gameManager.pendingDefensiveWarNotification = nil
        // Optionally navigate to War Room
        gameManager.navigationManager.currentView = .warRoom
    }
}

#Preview {
    DefensiveWarNotificationPopup(
        notification: DefensiveWarNotification(
            war: War(
                attacker: "CHN",
                defender: "USA",
                type: .offensive,
                justification: .territorialDispute,
                attackerStrength: 2_000_000,
                defenderStrength: 1_390_000,
                startDate: Date()
            ),
            aggressorName: "China",
            aggressorStrength: 2_000_000,
            playerStrength: 1_390_000,
            justification: .territorialDispute
        )
    )
    .environmentObject(GameManager.shared)
}
