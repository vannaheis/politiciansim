//
//  PositionView.swift
//  PoliticianSim
//
//  Career position and progression view
//

import SwiftUI

struct PositionView: View {
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

                    Text("Career Position")
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
                            // Current Position Card
                            CurrentPositionDetailCard(character: character)

                            // Career Path Card
                            CareerPathCard(character: character)

                            // Requirements for Next Position
                            if let nextPosition = getNextPosition(character: character) {
                                NextPositionRequirementsCard(
                                    currentCharacter: character,
                                    nextPosition: nextPosition
                                )
                            }

                            // Career Statistics
                            CareerStatisticsCard(character: character)
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

    private func getNextPosition(character: Character) -> Position? {
        // Get USA positions (hardcoded for now, will be from Country model later)
        let positions = USAPositions.allPositions

        guard let currentPos = character.currentPosition else {
            return positions.first // Return first position if no current position
        }

        // Find next position in hierarchy
        if let currentIndex = positions.firstIndex(where: { $0.id == currentPos.id }),
           currentIndex + 1 < positions.count {
            return positions[currentIndex + 1]
        }

        return nil // Already at highest position
    }
}

// MARK: - Current Position Detail Card

struct CurrentPositionDetailCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Position")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            if let position = character.currentPosition {
                VStack(spacing: 12) {
                    // Position title with icon
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Constants.Colors.achievement.opacity(0.2))
                                .frame(width: 48, height: 48)

                            Image(systemName: "star.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Constants.Colors.achievement)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(position.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)

                            Text("Level \(position.level)")
                                .font(.system(size: 13))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }

                        Spacer()
                    }

                    Divider()
                        .background(Color.white.opacity(0.2))

                    // Position details
                    VStack(spacing: 10) {
                        PositionDetailRow(
                            icon: "calendar",
                            label: "Term Length",
                            value: "\(position.termLengthYears) years"
                        )

                        PositionDetailRow(
                            icon: "person.badge.shield.checkmark",
                            label: "Minimum Age",
                            value: "\(position.minAge) years"
                        )
                    }
                }
            } else {
                // No current position
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Constants.Colors.secondaryText.opacity(0.2))
                                .frame(width: 48, height: 48)

                            Image(systemName: "person.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Citizen")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)

                            Text("No official position")
                                .font(.system(size: 13))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }

                        Spacer()
                    }

                    Text("Begin your political career by meeting the requirements for your first position.")
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .padding(.top, 4)
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

// MARK: - Career Path Card

struct CareerPathCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Career Progression Path")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 8) {
                ForEach(USAPositions.allPositions, id: \.id) { position in
                    CareerPathRow(
                        position: position,
                        isCurrentPosition: character.currentPosition?.id == position.id,
                        isPastPosition: character.careerHistory.contains(where: { $0.position.id == position.id }),
                        isLocked: !canAchievePosition(character: character, position: position)
                    )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func canAchievePosition(character: Character, position: Position) -> Bool {
        // Check age requirement
        if character.age < position.minAge {
            return false
        }

        // Check if requirements exist
        if let approvalReq = position.requirements.approvalRating,
           character.approvalRating < approvalReq {
            return false
        }

        if let repReq = position.requirements.reputation,
           character.reputation < repReq {
            return false
        }

        if let fundsReq = position.requirements.funds,
           character.campaignFunds < fundsReq {
            return false
        }

        return true
    }
}

struct CareerPathRow: View {
    let position: Position
    let isCurrentPosition: Bool
    let isPastPosition: Bool
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 28, height: 28)

                Image(systemName: statusIcon)
                    .font(.system(size: 12))
                    .foregroundColor(statusColor)
            }

            // Position info
            VStack(alignment: .leading, spacing: 2) {
                Text(position.title)
                    .font(.system(size: 13, weight: isCurrentPosition ? .bold : .medium))
                    .foregroundColor(isCurrentPosition ? .white : (isLocked ? Constants.Colors.secondaryText.opacity(0.6) : .white))

                Text("Level \(position.level) • Min Age \(position.minAge)")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
            }

            Spacer()

            // Lock icon if locked
            if isLocked && !isPastPosition && !isCurrentPosition {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText.opacity(0.5))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrentPosition ? Constants.Colors.buttonPrimary.opacity(0.15) : Color.clear)
        )
    }

    private var statusColor: Color {
        if isCurrentPosition {
            return Constants.Colors.achievement
        } else if isPastPosition {
            return Constants.Colors.positive
        } else if isLocked {
            return Constants.Colors.secondaryText.opacity(0.5)
        } else {
            return Constants.Colors.political
        }
    }

    private var statusIcon: String {
        if isCurrentPosition {
            return "star.fill"
        } else if isPastPosition {
            return "checkmark.circle.fill"
        } else if isLocked {
            return "lock.fill"
        } else {
            return "circle"
        }
    }
}

// MARK: - Next Position Requirements Card

struct NextPositionRequirementsCard: View {
    let currentCharacter: Character
    let nextPosition: Position

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.achievement)

                Text("Next: \(nextPosition.title)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 10) {
                // Age requirement
                RequirementRow(
                    icon: "calendar",
                    label: "Minimum Age",
                    requirement: "\(nextPosition.minAge) years",
                    current: "\(currentCharacter.age) years",
                    isMet: currentCharacter.age >= nextPosition.minAge
                )

                // Approval rating requirement
                if let approvalReq = nextPosition.requirements.approvalRating {
                    RequirementRow(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Approval Rating",
                        requirement: "\(Int(approvalReq))%",
                        current: "\(Int(currentCharacter.approvalRating))%",
                        isMet: currentCharacter.approvalRating >= approvalReq
                    )
                }

                // Reputation requirement
                if let repReq = nextPosition.requirements.reputation {
                    RequirementRow(
                        icon: "star.fill",
                        label: "Reputation",
                        requirement: "\(repReq)",
                        current: "\(currentCharacter.reputation)",
                        isMet: currentCharacter.reputation >= repReq
                    )
                }

                // Funds requirement
                if let fundsReq = nextPosition.requirements.funds {
                    RequirementRow(
                        icon: "dollarsign.circle.fill",
                        label: "Campaign Funds",
                        requirement: formatMoney(fundsReq),
                        current: formatMoney(currentCharacter.campaignFunds),
                        isMet: currentCharacter.campaignFunds >= fundsReq
                    )
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

struct RequirementRow: View {
    let icon: String
    let label: String
    let requirement: String
    let current: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(isMet ? Constants.Colors.positive : Constants.Colors.secondaryText)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(current)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isMet ? Constants.Colors.positive : .white)

                Text("/ \(requirement)")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
            }

            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(isMet ? Constants.Colors.positive : Constants.Colors.negative)
        }
    }
}

// MARK: - Career Statistics Card

struct CareerStatisticsCard: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Career Statistics")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                CareerStatRow(
                    icon: "briefcase.fill",
                    label: "Positions Held",
                    value: "\(character.careerHistory.count)"
                )

                CareerStatRow(
                    icon: "clock.fill",
                    label: "Years in Politics",
                    value: "\(max(0, character.age - 18))"
                )

                if let currentPos = character.currentPosition,
                   let entry = character.careerHistory.first(where: { $0.position.id == currentPos.id }) {
                    let timeInPosition = Calendar.current.dateComponents([.day], from: entry.startDate, to: character.currentDate).day ?? 0
                    let years = timeInPosition / 365
                    let months = (timeInPosition % 365) / 30

                    CareerStatRow(
                        icon: "timer",
                        label: "Time in Current Position",
                        value: years > 0 ? "\(years)y \(months)m" : "\(months)m"
                    )
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

struct CareerStatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Constants.Colors.political.opacity(0.2))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.political)
            }

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Supporting Views

struct PositionDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)
                .frame(width: 16)

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

// MARK: - USA Positions Helper

struct USAPositions {
    static let allPositions: [Position] = [
        Position(
            title: "Mayor",
            level: 1,
            termLengthYears: 4,
            minAge: 25,
            approvalRating: 35,
            reputation: 25,
            funds: 50000
        ),
        Position(
            title: "Governor",
            level: 2,
            termLengthYears: 4,
            minAge: 30,
            approvalRating: 50,
            reputation: 50,
            funds: 500000
        ),
        Position(
            title: "U.S. Senator",
            level: 3,
            termLengthYears: 6,
            minAge: 30,
            approvalRating: 55,
            reputation: 60,
            funds: 1000000
        ),
        Position(
            title: "Vice President",
            level: 4,
            termLengthYears: 4,
            minAge: 35,
            approvalRating: 60,
            reputation: 70,
            funds: 5000000
        ),
        Position(
            title: "President",
            level: 5,
            termLengthYears: 4,
            minAge: 35,
            approvalRating: 65,
            reputation: 80,
            funds: 10000000
        )
    ]
}

#Preview {
    PositionView()
        .environmentObject(GameManager.shared)
}
