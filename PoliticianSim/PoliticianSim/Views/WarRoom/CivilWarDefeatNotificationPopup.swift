//
//  CivilWarDefeatNotificationPopup.swift
//  PoliticianSim
//
//  Popup notification for civil war defeats (rebellion victory)
//

import SwiftUI

struct CivilWarDefeatNotificationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let notification: CivilWarDefeatNotification

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
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
            .padding(.top, 32)
            .padding(.bottom, 24)

            Divider()
                .background(Color.white.opacity(0.2))

            // Defeat Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Territory Lost")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                DefeatDetailRow(
                    icon: "mappin.slash.fill",
                    label: "Territory",
                    value: notification.territoryName,
                    color: Constants.Colors.negative
                )

                DefeatDetailRow(
                    icon: "map.fill",
                    label: "Size Lost",
                    value: notification.formattedTerritory,
                    color: Constants.Colors.negative
                )

                DefeatDetailRow(
                    icon: "person.3.fill",
                    label: "Population Lost",
                    value: notification.formattedPopulation,
                    color: Constants.Colors.negative
                )

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 8)

                Text("War Costs")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                DefeatDetailRow(
                    icon: "cross.fill",
                    label: "Casualties",
                    value: notification.formattedCasualties,
                    color: Constants.Colors.negative
                )

                DefeatDetailRow(
                    icon: "dollarsign.circle.fill",
                    label: "War Cost",
                    value: notification.formattedWarCost,
                    color: .orange
                )

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 8)

                Text("Political Consequences")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                DefeatDetailRow(
                    icon: "hand.thumbsdown.fill",
                    label: "Approval",
                    value: "\(Int(notification.approvalLoss))%",
                    color: Constants.Colors.negative
                )

                DefeatDetailRow(
                    icon: "star.slash.fill",
                    label: "Reputation",
                    value: "\(notification.reputationLoss)",
                    color: Constants.Colors.negative
                )

                DefeatDetailRow(
                    icon: "brain.head.profile",
                    label: "Stress",
                    value: "+\(notification.stressGain)",
                    color: .orange
                )
            }
            .padding(24)

            Divider()
                .background(Color.white.opacity(0.2))

            // Warning Message
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.orange)
                    Text("The territory has gained independence and is no longer under your control.")
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Action Button
            Button(action: {
                dismissNotification()
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Constants.Colors.negative)
                    .cornerRadius(8)
            }
            .padding(24)
            .padding(.top, 0)
        }
        .frame(width: 420)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
    }

    private func dismissNotification() {
        if !gameManager.pendingCivilWarDefeatNotifications.isEmpty {
            gameManager.pendingCivilWarDefeatNotifications.removeFirst()
        }
    }
}

// MARK: - Defeat Detail Row

struct DefeatDetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText)
                .frame(width: 120, alignment: .leading)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
