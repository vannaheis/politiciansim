//
//  GovernmentStatsView.swift
//  PoliticianSim
//
//  Government performance statistics view
//

import SwiftUI

struct GovernmentStatsView: View {
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

                    Text("Government Performance")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer to balance menu button
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if gameManager.governmentStatsManager.currentStats != nil {
                    StatsContentView()
                } else {
                    NoStatsView()
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .onAppear {
            // Initialize stats if character has a position
            if gameManager.governmentStatsManager.currentStats == nil,
               let character = gameManager.character,
               character.currentPosition != nil {
                gameManager.governmentStatsManager.initializeStats(for: character)

                // Calculate initial scores if budget exists
                if let budget = gameManager.budgetManager.currentBudget,
                   var character = gameManager.character {
                    let population = getPopulation(character: character)
                    gameManager.governmentStatsManager.updateStats(
                        budget: budget,
                        population: population,
                        character: &character
                    )
                    gameManager.characterManager.updateCharacter(character)
                }
            }
        }
    }

    private func getPopulation(character: Character) -> Int {
        guard let position = character.currentPosition else { return 1 }

        switch position.level {
        case 1: return gameManager.economicDataManager.economicData.local.gdp.current > 0 ?
            Int(gameManager.economicDataManager.economicData.local.gdp.current / 50000) : 100_000
        case 2: return Int(gameManager.economicDataManager.economicData.state.gdp.current /
            (gameManager.economicDataManager.economicData.state.gdp.current / 10_000_000))
        case 3, 4, 5:
            if let usa = gameManager.economicDataManager.economicData.worldGDPs.first(where: { $0.countryCode == "USA" }) {
                return usa.population
            }
            return 335_000_000
        default: return 1
        }
    }
}

// MARK: - Stats Content View

struct StatsContentView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let summary = gameManager.governmentStatsManager.getStatsSummary() {
                    // Overall Score Card
                    OverallScoreCard(summary: summary)

                    // Department Scores Grid
                    DepartmentScoresGrid(scores: summary.allScores)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Overall Score Card

struct OverallScoreCard: View {
    let summary: GovernmentStatsManager.StatsSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 12))
                    .foregroundColor(getScoreColor(summary.overallScore))

                Text("Overall Government Performance")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            VStack(spacing: 16) {
                // Overall score display
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", summary.overallScore))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(getScoreColor(summary.overallScore))

                    Text(getScoreLabel(summary.overallScore))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(getScoreColor(summary.overallScore))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(getScoreColor(summary.overallScore).opacity(0.2))
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Best and worst departments
                HStack(spacing: 16) {
                    if let highest = summary.highestDepartment {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Best Performing")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack(spacing: 6) {
                                Image(systemName: highest.icon)
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.Colors.positive)

                                Text(highest.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text(String(format: "%.1f", highest.score))
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.positive)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let lowest = summary.lowestDepartment {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Needs Improvement")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack(spacing: 6) {
                                Image(systemName: lowest.icon)
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.Colors.negative)

                                Text(lowest.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text(String(format: "%.1f", lowest.score))
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.negative)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func getScoreColor(_ score: Double) -> Color {
        if score >= 80 {
            return Constants.Colors.positive
        } else if score >= 60 {
            return Color(red: 0.4, green: 0.7, blue: 0.9)
        } else if score >= 40 {
            return .orange
        } else {
            return Constants.Colors.negative
        }
    }

    private func getScoreLabel(_ score: Double) -> String {
        if score >= 80 {
            return "EXCELLENT"
        } else if score >= 60 {
            return "GOOD"
        } else if score >= 40 {
            return "FAIR"
        } else if score >= 20 {
            return "POOR"
        } else {
            return "CRITICAL"
        }
    }
}

// MARK: - Department Scores Grid

struct DepartmentScoresGrid: View {
    let scores: [DepartmentScoreInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Department Scores")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 8) {
                ForEach(scores, id: \.name) { scoreInfo in
                    DepartmentScoreRow(scoreInfo: scoreInfo)
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

struct DepartmentScoreRow: View {
    let scoreInfo: DepartmentScoreInfo

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(
                            red: scoreInfo.color.red,
                            green: scoreInfo.color.green,
                            blue: scoreInfo.color.blue
                        ).opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: scoreInfo.icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(
                            red: scoreInfo.color.red,
                            green: scoreInfo.color.green,
                            blue: scoreInfo.color.blue
                        ))
                }

                // Department name
                VStack(alignment: .leading, spacing: 2) {
                    Text(scoreInfo.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)

                    Text(scoreInfo.description)
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                // Score display
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f", scoreInfo.score))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(
                            red: scoreInfo.scoreColor.red,
                            green: scoreInfo.scoreColor.green,
                            blue: scoreInfo.scoreColor.blue
                        ))

                    Text(scoreInfo.scoreLabel)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(
                            red: scoreInfo.scoreColor.red,
                            green: scoreInfo.scoreColor.green,
                            blue: scoreInfo.scoreColor.blue
                        ))
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(
                            red: scoreInfo.scoreColor.red,
                            green: scoreInfo.scoreColor.green,
                            blue: scoreInfo.scoreColor.blue
                        ))
                        .frame(width: geometry.size.width * (scoreInfo.score / 100.0), height: 4)
                }
            }
            .frame(height: 4)

            Divider()
                .background(Color.white.opacity(0.1))
        }
    }
}

// MARK: - No Stats View

struct NoStatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.3))

            VStack(spacing: 8) {
                Text("No Performance Data Available")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("You need an official government position and budget to track performance.")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    GovernmentStatsView()
        .environmentObject(GameManager.shared)
}
