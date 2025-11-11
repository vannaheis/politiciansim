//
//  StatCard.swift
//  PoliticianSim
//
//  Displays a stat with icon, label, and value
//

import SwiftUI

struct StatCard: View {
    let iconName: String
    let iconColor: Color
    let label: String
    let value: String
    let valueColor: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: Constants.Typography.bodyTextSize, weight: .medium))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(value)
                    .font(.system(size: Constants.Typography.heroNumberSize, weight: .bold))
                    .foregroundColor(valueColor)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        StatCard(
            iconName: "star.fill",
            iconColor: Constants.Colors.charisma,
            label: "Charisma",
            value: "85",
            valueColor: .white
        )

        StatCard(
            iconName: "brain.head.profile",
            iconColor: Constants.Colors.intelligence,
            label: "Intelligence",
            value: "72",
            valueColor: .white
        )

        StatCard(
            iconName: "heart.fill",
            iconColor: .red,
            label: "Approval Rating",
            value: "45%",
            valueColor: Constants.Colors.approvalGood
        )
    }
    .padding()
    .background(Constants.Colors.background)
}
