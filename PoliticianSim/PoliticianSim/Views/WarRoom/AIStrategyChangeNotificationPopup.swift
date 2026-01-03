//
//  AIStrategyChangeNotificationPopup.swift
//  PoliticianSim
//
//  Notification popup for AI strategy changes
//

import SwiftUI

struct AIStrategyChangeNotificationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let notification: AIStrategyChangeNotification
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: notification.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.orange)

                    Text(notification.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(notification.message)
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 20)

                // Strategy Change Details
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        // Old Strategy
                        VStack(spacing: 8) {
                            Text("PREVIOUS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Image(systemName: notification.oldStrategy.icon)
                                .font(.system(size: 32))
                                .foregroundColor(.white)

                            Text(notification.oldStrategy.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)

                        // New Strategy
                        VStack(spacing: 8) {
                            Text("NEW STRATEGY")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Image(systemName: notification.newStrategy.icon)
                                .font(.system(size: 32))
                                .foregroundColor(.orange)

                            Text(notification.newStrategy.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Strategy Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WHAT THIS MEANS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(notification.newStrategy.description)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.2, green: 0.22, blue: 0.27))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 24)

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 20)

                // Dismiss Button
                Button(action: onDismiss) {
                    Text("Understood")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(width: 420)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "CHN",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 100_000,
        defenderStrength: 80_000,
        startDate: Date()
    )

    let notification = AIStrategyChangeNotification(
        war: war,
        enemyCountryName: "China",
        oldStrategy: .balanced,
        newStrategy: .defensive
    )

    return AIStrategyChangeNotificationPopup(
        notification: notification,
        onDismiss: {}
    )
    .environmentObject(GameManager.shared)
}
