//
//  WarExhaustionWarningPopup.swift
//  PoliticianSim
//
//  War exhaustion warning notification
//

import SwiftUI

struct WarExhaustionWarningPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let warning: WarExhaustionWarning

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: warning.icon)
                    .font(.system(size: 50))
                    .foregroundColor(iconColor)

                Text(warning.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)

            // Exhaustion Meter
            VStack(spacing: 8) {
                HStack {
                    Text("Exhaustion Level")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Spacer()

                    Text(warning.war.formattedExhaustion)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(iconColor)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                            .cornerRadius(6)

                        Rectangle()
                            .fill(iconColor)
                            .frame(width: geometry.size.width * CGFloat(warning.war.warExhaustion), height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)

            // Message
            ScrollView {
                Text(warning.message)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
            }
            .frame(maxHeight: 200)

            // War Stats
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(warning.war.formattedDuration)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Your Casualties")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("\(abs(warning.war.casualtiesByCountry[warning.playerCountry] ?? 0))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Constants.Colors.negative)
                    }
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly Approval Penalty")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("\(String(format: "%.1f", warning.exhaustionLevel.weeklyApprovalPenalty))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Constants.Colors.negative)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Weekly Stress")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("+\(warning.exhaustionLevel.weeklyStressIncrease)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Constants.Colors.negative)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.2))

            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Navigate to War Room
                    gameManager.navigateTo(.warRoom)
                    gameManager.pendingExhaustionWarning = nil
                }) {
                    Text("View Active Wars")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.buttonPrimary)
                        .cornerRadius(10)
                }

                Button(action: {
                    // Dismiss warning
                    gameManager.pendingExhaustionWarning = nil
                }) {
                    Text("Dismiss")
                        .font(.system(size: 15))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .frame(width: 380)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(20)
        .shadow(radius: 30)
    }

    var iconColor: Color {
        switch warning.iconColor {
        case "green": return Constants.Colors.positive
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return Constants.Colors.negative
        default: return .white
        }
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "CHN",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 1_400_000,
        defenderStrength: 2_035_000,
        startDate: Date().addingTimeInterval(-180 * 24 * 60 * 60)  // 180 days ago
    )

    var warWithExhaustion = war
    warWithExhaustion.warExhaustion = 0.7

    let warning = WarExhaustionWarning(
        war: warWithExhaustion,
        exhaustionLevel: .high,
        playerCountry: "USA"
    )

    return ZStack {
        Color.black.opacity(0.7)
            .ignoresSafeArea()

        WarExhaustionWarningPopup(warning: warning)
            .environmentObject(GameManager.shared)
    }
}
