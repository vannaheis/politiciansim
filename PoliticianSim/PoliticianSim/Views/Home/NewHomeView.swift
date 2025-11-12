//
//  NewHomeView.swift
//  PoliticianSim
//
//  Redesigned home view matching reference design
//

import SwiftUI

struct NewHomeView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header
                HStack(spacing: 0) {
                    // Hamburger menu button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.navigationManager.toggleMenu()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    // Time controls
                    HStack(spacing: 12) {
                        // Day button
                        Button(action: {
                            gameManager.skipDay()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10))
                                Text("Day")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(Constants.Colors.secondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }

                        // Week button
                        Button(action: {
                            gameManager.skipWeek()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10))
                                Text("Week")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Constants.Colors.buttonPrimary)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Money/Level badge
                if let character = gameManager.character {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.money)

                        Text("\(Int(truncating: character.campaignFunds as NSDecimalNumber))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Constants.Colors.money)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Constants.Colors.money.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let character = gameManager.character {
                            // Character info
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Constants.Colors.buttonPrimary)

                                    Text(character.name)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                Text("Age \(character.age) • \(formattedDate(character.currentDate))")
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                            .padding(.top, 12)

                            // Country stats card
                            CountryStatsCard(character: character)

                            // Character attributes
                            CharacterAttributesCard(character: character)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)

            // Event dialog overlay
            if let activeEvent = gameManager.gameState.activeEvent {
                EventDialog(
                    event: activeEvent,
                    onChoiceSelected: { choice in
                        gameManager.handleEventChoice(choice)
                    },
                    onDismiss: {
                        gameManager.dismissEvent()
                    }
                )
                .transition(.opacity)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Country Stats Card

struct CountryStatsCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Country Overview")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                CountryStatRow(
                    icon: "flag.fill",
                    iconColor: Constants.Colors.political,
                    label: "Nation",
                    value: character.country
                )

                CountryStatRow(
                    icon: "person.3.fill",
                    iconColor: .blue,
                    label: "Population",
                    value: "328M" // TODO: Add to Character model
                )

                CountryStatRow(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: Constants.Colors.positive,
                    label: "GDP",
                    value: "$21.4T" // TODO: Add to Country model
                )

                CountryStatRow(
                    icon: "percent",
                    iconColor: Constants.Colors.reputation,
                    label: "Approval Rating",
                    value: "\(Int(character.approvalRating))%"
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct CountryStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(iconColor)
            }

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Character Attributes Card

struct CharacterAttributesCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Attributes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                AttributeStatRow(
                    icon: Constants.Icons.Attributes.charisma,
                    iconColor: Constants.Colors.charisma,
                    label: "Charisma",
                    value: character.charisma
                )

                AttributeStatRow(
                    icon: Constants.Icons.Attributes.intelligence,
                    iconColor: Constants.Colors.intelligence,
                    label: "Intelligence",
                    value: character.intelligence
                )

                AttributeStatRow(
                    icon: Constants.Icons.Attributes.reputation,
                    iconColor: Constants.Colors.reputation,
                    label: "Reputation",
                    value: character.reputation
                )

                AttributeStatRow(
                    icon: Constants.Icons.Attributes.luck,
                    iconColor: Constants.Colors.luck,
                    label: "Luck",
                    value: character.luck
                )

                AttributeStatRow(
                    icon: Constants.Icons.Attributes.diplomacy,
                    iconColor: Constants.Colors.diplomacyColor,
                    label: "Diplomacy",
                    value: character.diplomacy
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct AttributeStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(iconColor)
            }

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text("\(value)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(valueColor(for: value))
        }
    }

    private func valueColor(for value: Int) -> Color {
        if value >= 70 {
            return Constants.Colors.positive
        } else if value >= 40 {
            return .white
        } else {
            return Constants.Colors.negative
        }
    }
}

#Preview {
    NewHomeView()
        .environmentObject(GameManager.shared)
}
