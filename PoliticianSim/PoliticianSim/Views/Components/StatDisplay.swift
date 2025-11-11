//
//  StatDisplay.swift
//  PoliticianSim
//
//  Combined stat visualization with icon and progress
//

import SwiftUI

struct StatDisplay: View {
    let iconName: String
    let iconColor: Color
    let label: String
    let value: Int
    let maxValue: Int

    var progress: Double {
        Double(value) / Double(maxValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                // Label and value
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: Constants.Typography.captionSize, weight: .medium))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(value)/\(maxValue)")
                        .font(.system(size: Constants.Typography.bodyTextSize, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()
            }

            // Progress bar
            ProgressBar(value: progress, color: iconColor)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        StatDisplay(
            iconName: "star.fill",
            iconColor: Constants.Colors.charisma,
            label: "Charisma",
            value: 85,
            maxValue: 100
        )

        StatDisplay(
            iconName: "brain.head.profile",
            iconColor: Constants.Colors.intelligence,
            label: "Intelligence",
            value: 72,
            maxValue: 100
        )

        StatDisplay(
            iconName: "heart.fill",
            iconColor: Constants.Colors.health,
            label: "Health",
            value: 45,
            maxValue: 100
        )

        StatDisplay(
            iconName: "exclamationmark.triangle.fill",
            iconColor: Constants.Colors.stress,
            label: "Stress",
            value: 88,
            maxValue: 100
        )
    }
    .padding()
    .background(Constants.Colors.background)
}
