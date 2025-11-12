//
//  ProfileView.swift
//  PoliticianSim
//
//  Character profile view displaying full character information
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header with menu button
                HStack {
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

                    Text("Profile")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer to balance menu button
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    if let character = gameManager.character {
                        VStack(alignment: .leading, spacing: 16) {
                            // Character header card
                            CharacterHeaderCard(character: character)

                            // Background & Demographics
                            ProfileBackgroundCard(character: character)

                            // Current Position
                            CurrentPositionCard(character: character)

                            // Base Attributes
                            BaseAttributesCard(character: character)

                            // Secondary Stats
                            SecondaryStatsCard(character: character)

                            // Career History
                            CareerHistoryCard(character: character)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
    }
}

// MARK: - Character Header Card

struct CharacterHeaderCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Character avatar placeholder
            ZStack {
                Circle()
                    .fill(Constants.Colors.buttonPrimary.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Constants.Colors.buttonPrimary)
            }

            Text(character.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Age \(character.age)")
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText)

            if let currentPosition = character.currentPosition {
                Text(currentPosition.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Constants.Colors.political)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Profile Background Card

struct ProfileBackgroundCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                ProfileInfoRow(
                    icon: "flag.fill",
                    iconColor: Constants.Colors.political,
                    label: "Country",
                    value: character.country
                )

                ProfileInfoRow(
                    icon: character.gender == .male ? "person.fill" : character.gender == .female ? "person.fill" : "person.fill",
                    iconColor: .blue,
                    label: "Gender",
                    value: character.gender.rawValue
                )

                ProfileInfoRow(
                    icon: "building.2.fill",
                    iconColor: Constants.Colors.reputation,
                    label: "Background",
                    value: character.background.rawValue
                )

                ProfileInfoRow(
                    icon: "calendar",
                    iconColor: Constants.Colors.secondaryText,
                    label: "Birth Date",
                    value: formattedDate(character.birthDate)
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Current Position Card

struct CurrentPositionCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Position")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            if let position = character.currentPosition {
                VStack(spacing: 10) {
                    ProfileInfoRow(
                        icon: "star.fill",
                        iconColor: Constants.Colors.achievement,
                        label: "Title",
                        value: position.title
                    )

                    ProfileInfoRow(
                        icon: "chart.bar.fill",
                        iconColor: Constants.Colors.political,
                        label: "Level",
                        value: "\(position.level)"
                    )

                    ProfileInfoRow(
                        icon: "clock.fill",
                        iconColor: Constants.Colors.secondaryText,
                        label: "Term Length",
                        value: "\(position.termLengthYears) years"
                    )
                }
            } else {
                Text("No current position")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .padding(.vertical, 8)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Base Attributes Card

struct BaseAttributesCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Attributes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                AttributeProgressRow(
                    icon: Constants.Icons.Attributes.charisma,
                    iconColor: Constants.Colors.charisma,
                    label: "Charisma",
                    value: character.charisma
                )

                AttributeProgressRow(
                    icon: Constants.Icons.Attributes.intelligence,
                    iconColor: Constants.Colors.intelligence,
                    label: "Intelligence",
                    value: character.intelligence
                )

                AttributeProgressRow(
                    icon: Constants.Icons.Attributes.reputation,
                    iconColor: Constants.Colors.reputation,
                    label: "Reputation",
                    value: character.reputation
                )

                AttributeProgressRow(
                    icon: Constants.Icons.Attributes.luck,
                    iconColor: Constants.Colors.luck,
                    label: "Luck",
                    value: character.luck
                )

                AttributeProgressRow(
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

// MARK: - Secondary Stats Card

struct SecondaryStatsCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Secondary Stats")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                ProfileInfoRow(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: Constants.Colors.political,
                    label: "Approval Rating",
                    value: "\(Int(character.approvalRating))%"
                )

                ProfileInfoRow(
                    icon: "dollarsign.circle.fill",
                    iconColor: Constants.Colors.money,
                    label: "Campaign Funds",
                    value: formatMoney(character.campaignFunds)
                )

                ProfileInfoRow(
                    icon: "heart.fill",
                    iconColor: Constants.Colors.health,
                    label: "Health",
                    value: "\(character.health)/100"
                )

                ProfileInfoRow(
                    icon: "bolt.fill",
                    iconColor: Constants.Colors.stress,
                    label: "Stress",
                    value: "\(character.stress)/100"
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Career History Card

struct CareerHistoryCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Career History")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            if character.careerHistory.isEmpty {
                Text("No career history yet")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(character.careerHistory.reversed(), id: \.startDate) { entry in
                        CareerHistoryRow(entry: entry)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct CareerHistoryRow: View {
    let entry: CareerEntry

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Constants.Colors.political.opacity(0.2))
                    .frame(width: 28, height: 28)

                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.political)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.position.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)

                Text("\(formattedDate(entry.startDate)) - \(entry.endDate.map { formattedDate($0) } ?? "Present")")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Profile Info Row

struct ProfileInfoRow: View {
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
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Attribute Progress Row

struct AttributeProgressRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(iconColor)
                        .frame(width: 16)

                    Text(label)
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Spacer()

                Text("\(value)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(valueColor(for: value))
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(iconColor)
                        .frame(width: geometry.size.width * CGFloat(value) / 100.0, height: 6)
                }
            }
            .frame(height: 6)
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
    ProfileView()
        .environmentObject(GameManager.shared)
}
