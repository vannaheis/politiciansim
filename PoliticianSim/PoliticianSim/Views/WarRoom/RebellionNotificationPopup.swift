//
//  RebellionNotificationPopup.swift
//  PoliticianSim
//
//  Displays notification when a rebellion starts in a conquered territory
//

import SwiftUI

struct RebellionNotificationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let notification: RebellionNotification

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(red: notification.threatColor.red,
                                          green: notification.threatColor.green,
                                          blue: notification.threatColor.blue))

                Text(notification.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(notification.subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Rebellion Details
            VStack(spacing: 16) {
                Text("Rebellion Information")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Territory Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(Constants.Colors.buttonPrimary)
                        Text("Territory:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text(notification.rebellion.territory.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(Constants.Colors.buttonPrimary)
                        Text("Population:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text(notification.rebellion.territory.formattedPopulation)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .foregroundColor(Constants.Colors.buttonPrimary)
                        Text("Morale:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text("\(Int(notification.rebellion.territory.morale * 100))%")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Constants.Colors.negative)
                    }

                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(Constants.Colors.buttonPrimary)
                        Text("Popular Support:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text("\(Int(notification.rebellion.support * 100))%")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Constants.Colors.negative)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)

                // Military Strength Comparison
                VStack(spacing: 12) {
                    Text("MILITARY STRENGTH")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rebel Forces")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(notification.formattedRebelStrength)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Constants.Colors.negative)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Your Forces")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(notification.formattedPlayerStrength)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Constants.Colors.accent)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)

                // Threat Assessment
                HStack {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: notification.threatColor.red,
                                              green: notification.threatColor.green,
                                              blue: notification.threatColor.blue))

                    Text(notification.threatLevel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: notification.threatColor.red,
                                              green: notification.threatColor.green,
                                              blue: notification.threatColor.blue))

                    Spacer()
                }
                .padding(12)
                .background(Color(red: notification.threatColor.red,
                                green: notification.threatColor.green,
                                blue: notification.threatColor.blue).opacity(0.15))
                .cornerRadius(8)

                // Consequences
                VStack(alignment: .leading, spacing: 8) {
                    Text("CONSEQUENCES")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.negative)
                            Text("Territory GDP contribution suspended")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.negative)
                            Text("Approval rating may decline if not addressed")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.negative)
                            Text("Territory may gain independence if rebellion succeeds")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(12)
                .background(Constants.Colors.negative.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    dismissNotification()
                }) {
                    Text("Acknowledge")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.25, green: 0.27, blue: 0.32))
                        .cornerRadius(8)
                }

                Button(action: {
                    dismissNotification()
                    gameManager.navigationManager.navigateTo(.warRoom)
                }) {
                    Text("Go to War Room")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.buttonPrimary)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 420)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private func dismissNotification() {
        if !gameManager.pendingRebellionNotifications.isEmpty {
            gameManager.pendingRebellionNotifications.removeFirst()
        }
    }
}

#Preview {
    let territory = Territory(
        name: "Eastern Provinces",
        formerOwner: "CHN",
        currentOwner: "USA",
        size: 3_700_000,
        population: 45_000_000,
        conquestDate: Date().addingTimeInterval(-180 * 24 * 60 * 60)
    )

    let rebellion = Rebellion(territory: territory, currentDate: Date())

    let notification = RebellionNotification(
        rebellion: rebellion,
        playerMilitaryStrength: 1_400_000
    )

    return RebellionNotificationPopup(notification: notification)
        .environmentObject(GameManager.shared)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
}
