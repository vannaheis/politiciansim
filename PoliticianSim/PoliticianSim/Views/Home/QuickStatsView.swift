//
//  QuickStatsView.swift
//  PoliticianSim
//
//  Quick overview of character stats
//

import SwiftUI

struct QuickStatsView: View {
    let character: Character

    var body: some View {
        InfoCard(title: "Your Attributes") {
            VStack(spacing: 12) {
                StatDisplay(
                    iconName: Constants.Icons.Attributes.charisma,
                    iconColor: Constants.Colors.charisma,
                    label: "Charisma",
                    value: character.charisma,
                    maxValue: 100
                )

                StatDisplay(
                    iconName: Constants.Icons.Attributes.intelligence,
                    iconColor: Constants.Colors.intelligence,
                    label: "Intelligence",
                    value: character.intelligence,
                    maxValue: 100
                )

                StatDisplay(
                    iconName: Constants.Icons.Attributes.reputation,
                    iconColor: Constants.Colors.reputation,
                    label: "Reputation",
                    value: character.reputation,
                    maxValue: 100
                )

                StatDisplay(
                    iconName: Constants.Icons.Attributes.luck,
                    iconColor: Constants.Colors.luck,
                    label: "Luck",
                    value: character.luck,
                    maxValue: 100
                )

                StatDisplay(
                    iconName: Constants.Icons.Attributes.diplomacy,
                    iconColor: Constants.Colors.diplomacyColor,
                    label: "Diplomacy",
                    value: character.diplomacy,
                    maxValue: 100
                )
            }
        }
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()
        QuickStatsView(character: {
            let gm = GameManager.shared
            gm.createTestCharacter()
            return gm.character!
        }())
        .padding()
    }
}
