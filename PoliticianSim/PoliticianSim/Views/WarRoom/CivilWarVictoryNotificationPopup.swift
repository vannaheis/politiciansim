//
//  CivilWarVictoryNotificationPopup.swift
//  PoliticianSim
//
//  Popup notification for civil war victories (rebellion suppression)
//

import SwiftUI

struct CivilWarVictoryNotificationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let notification: CivilWarVictoryNotification

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)

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

            // Victory Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Territory Secured")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                VictoryDetailRow(
                    icon: "mappin.circle.fill",
                    label: "Territory",
                    value: notification.territoryName,
                    color: .blue
                )

                VictoryDetailRow(
                    icon: "map.fill",
                    label: "Size",
                    value: notification.formattedTerritory,
                    color: .blue
                )

                VictoryDetailRow(
                    icon: "person.3.fill",
                    label: "Population",
                    value: notification.formattedPopulation,
                    color: .blue
                )

                VictoryDetailRow(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "New Morale",
                    value: "\(Int(notification.newMorale * 100))%",
                    color: .green
                )

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 8)

                Text("War Costs")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                VictoryDetailRow(
                    icon: "cross.fill",
                    label: "Casualties",
                    value: notification.formattedCasualties,
                    color: Constants.Colors.negative
                )

                VictoryDetailRow(
                    icon: "dollarsign.circle.fill",
                    label: "War Cost",
                    value: notification.formattedWarCost,
                    color: .orange
                )

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 8)

                Text("Political Impact")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                VictoryDetailRow(
                    icon: "hand.thumbsup.fill",
                    label: "Approval",
                    value: "+\(Int(notification.approvalGain))%",
                    color: .green
                )
            }
            .padding(24)

            Divider()
                .background(Color.white.opacity(0.2))

            // Action Button
            Button(action: {
                dismissNotification()
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(24)
        }
        .frame(width: 420)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
    }

    private func dismissNotification() {
        if !gameManager.pendingCivilWarVictoryNotifications.isEmpty {
            gameManager.pendingCivilWarVictoryNotifications.removeFirst()
        }
    }
}

// MARK: - Victory Detail Row

struct VictoryDetailRow: View {
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
                .frame(width: 100, alignment: .leading)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
