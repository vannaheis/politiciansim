//
//  StatsView.swift
//  PoliticianSim
//
//  Detailed statistics and tracking view
//

import SwiftUI

struct StatsView: View {
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

                    Text("Statistics")
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
                            // Overview Card
                            StatsOverviewCard(character: character)

                            // Core Attributes
                            CoreAttributesStatsCard(character: character)

                            // Political Stats
                            PoliticalStatsCard(character: character)

                            // Personal Stats
                            PersonalStatsCard(character: character)

                            // Approval History
                            ApprovalHistoryCard(gameManager: gameManager)
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

// MARK: - Stats Overview Card

struct StatsOverviewCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            HStack(spacing: 16) {
                OverviewStatItem(
                    icon: "calendar",
                    iconColor: Constants.Colors.political,
                    label: "Age",
                    value: "\(character.age)"
                )

                OverviewStatItem(
                    icon: "star.fill",
                    iconColor: Constants.Colors.achievement,
                    label: "Position",
                    value: character.currentPosition?.title ?? "Citizen"
                )
            }

            HStack(spacing: 16) {
                OverviewStatItem(
                    icon: "dollarsign.circle.fill",
                    iconColor: Constants.Colors.money,
                    label: "Funds",
                    value: formatMoney(character.campaignFunds)
                )

                OverviewStatItem(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: Constants.Colors.political,
                    label: "Approval",
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

    private func formatMoney(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        let value = number.doubleValue

        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.1fK", value / 1_000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

struct OverviewStatItem: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Core Attributes Stats Card

struct CoreAttributesStatsCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Core Attributes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 12) {
                DetailedStatRow(
                    icon: Constants.Icons.Attributes.charisma,
                    iconColor: Constants.Colors.charisma,
                    label: "Charisma",
                    value: character.charisma,
                    description: "Ability to influence and persuade"
                )

                DetailedStatRow(
                    icon: Constants.Icons.Attributes.intelligence,
                    iconColor: Constants.Colors.intelligence,
                    label: "Intelligence",
                    value: character.intelligence,
                    description: "Problem-solving and strategic thinking"
                )

                DetailedStatRow(
                    icon: Constants.Icons.Attributes.reputation,
                    iconColor: Constants.Colors.reputation,
                    label: "Reputation",
                    value: character.reputation,
                    description: "Public standing and credibility"
                )

                DetailedStatRow(
                    icon: Constants.Icons.Attributes.luck,
                    iconColor: Constants.Colors.luck,
                    label: "Luck",
                    value: character.luck,
                    description: "Fortune in random events"
                )

                DetailedStatRow(
                    icon: Constants.Icons.Attributes.diplomacy,
                    iconColor: Constants.Colors.diplomacyColor,
                    label: "Diplomacy",
                    value: character.diplomacy,
                    description: "International relations skill"
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

// MARK: - Political Stats Card

struct PoliticalStatsCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Political Metrics")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 12) {
                StatRowWithBar(
                    icon: "percent",
                    iconColor: Constants.Colors.political,
                    label: "Approval Rating",
                    value: Int(character.approvalRating),
                    maxValue: 100,
                    showPercentage: true
                )

                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Constants.Colors.money.opacity(0.2))
                            .frame(width: 28, height: 28)

                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.money)
                    }

                    Text("Campaign Funds")
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Spacer()

                    Text(formatMoney(character.campaignFunds))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Constants.Colors.money)
                }
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
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Personal Stats Card

struct PersonalStatsCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Wellbeing")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 12) {
                StatRowWithBar(
                    icon: "heart.fill",
                    iconColor: Constants.Colors.health,
                    label: "Health",
                    value: character.health,
                    maxValue: 100,
                    showPercentage: false
                )

                StatRowWithBar(
                    icon: "bolt.fill",
                    iconColor: Constants.Colors.stress,
                    label: "Stress",
                    value: character.stress,
                    maxValue: 100,
                    showPercentage: false
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

// MARK: - Approval History Card

struct ApprovalHistoryCard: View {
    let gameManager: GameManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Approval History")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            if gameManager.statManager.approvalHistory.isEmpty {
                Text("No approval history yet")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Simple approval history list
                VStack(spacing: 8) {
                    ForEach(gameManager.statManager.approvalHistory.suffix(10).reversed(), id: \.date) { record in
                        ApprovalHistoryRow(record: record)
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

struct ApprovalHistoryRow: View {
    let record: ApprovalHistory

    var body: some View {
        HStack(spacing: 10) {
            Text(formattedDate(record.date))
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text("\(Int(record.rating))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ratingColor(record.rating))
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func ratingColor(_ rating: Double) -> Color {
        if rating >= 60 {
            return Constants.Colors.positive
        } else if rating >= 40 {
            return .white
        } else {
            return Constants.Colors.negative
        }
    }
}

// MARK: - Supporting Views

struct DetailedStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Int
    let description: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(iconColor)
                        .frame(width: 16)

                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("\(value)")
                    .font(.system(size: 14, weight: .bold))
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

            Text(description)
                .font(.system(size: 11))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
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

struct StatRowWithBar: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Int
    let maxValue: Int
    let showPercentage: Bool

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

                Text(showPercentage ? "\(value)%" : "\(value)")
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
                        .frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: 6)
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
    StatsView()
        .environmentObject(GameManager.shared)
}
