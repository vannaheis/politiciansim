//
//  CharacterOverviewCard.swift
//  PoliticianSim
//
//  Main character info card
//

import SwiftUI

struct CharacterOverviewCard: View {
    let character: Character

    var body: some View {
        InfoCard(title: character.name) {
            VStack(spacing: 16) {
                // Basic info row
                HStack(spacing: 20) {
                    // Gender & Background
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(
                            icon: "person.fill",
                            label: "Gender",
                            value: character.gender.rawValue.capitalized
                        )

                        InfoRow(
                            icon: "house.fill",
                            label: "Background",
                            value: character.background.rawValue.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized
                        )
                    }

                    Spacer()

                    // Country flag
                    VStack(spacing: 8) {
                        Text("🇺🇸")
                            .font(.system(size: 48))

                        Text(character.country)
                            .font(.system(size: Constants.Typography.captionSize, weight: .medium))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.2))

                // Health and Stress bars
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(Constants.Colors.health)
                                .font(.system(size: 14))

                            Text("Health")
                                .font(.system(size: Constants.Typography.bodyTextSize, weight: .medium))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text("\(character.health)/100")
                            .font(.system(size: Constants.Typography.bodyTextSize, weight: .bold))
                            .foregroundColor(.white)
                    }

                    ProgressBar(value: Double(character.health) / 100.0, color: Constants.Colors.health)

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Constants.Colors.stress)
                                .font(.system(size: 14))

                            Text("Stress")
                                .font(.system(size: Constants.Typography.bodyTextSize, weight: .medium))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text("\(character.stress)/100")
                            .font(.system(size: Constants.Typography.bodyTextSize, weight: .bold))
                            .foregroundColor(.white)
                    }

                    ProgressBar(value: Double(character.stress) / 100.0, color: Constants.Colors.stress)
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: Constants.Typography.captionSize))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(value)
                    .font(.system(size: Constants.Typography.bodyTextSize, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()
        CharacterOverviewCard(character: {
            let gm = GameManager.shared
            gm.createTestCharacter()
            return gm.character!
        }())
        .padding()
    }
}
