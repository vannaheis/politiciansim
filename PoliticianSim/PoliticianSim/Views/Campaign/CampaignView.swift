//
//  CampaignView.swift
//  PoliticianSim
//
//  Campaign management and activities view
//

import SwiftUI

struct CampaignView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header
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

                    Text("Campaign")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if let campaign = gameManager.electionManager.activeCampaign,
                   let character = gameManager.character {
                    // Active campaign content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Campaign status card
                            CampaignStatusCard(campaign: campaign, character: character)

                            // Campaign activities
                            CampaignActivitiesCard(character: character)

                            // Recent activity log
                            if !campaign.activities.isEmpty {
                                ActivityLogCard(activities: campaign.activities)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                } else if let character = gameManager.character {
                    // No active campaign - show start campaign
                    NoCampaignView(character: character)
                } else {
                    PlaceholderEmptyState(message: "No character found")
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
    }
}

// MARK: - Campaign Status Card

struct CampaignStatusCard: View {
    let campaign: Campaign
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Running for position
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.political.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: "flag.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.political)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Running for")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(campaign.targetPosition.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Poll numbers
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Poll Numbers")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Spacer()

                    Text("\(Int(campaign.pollNumbers))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(pollNumberColor)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(pollNumberColor)
                            .frame(width: geometry.size.width * CGFloat(campaign.pollNumbers / 100.0))
                    }
                }
                .frame(height: 8)
            }

            // Days remaining
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text("\(campaign.daysRemaining) days until election")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            // Campaign funds
            HStack(spacing: 12) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.money)

                Text("$\(formattedFunds)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.money)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private var pollNumberColor: Color {
        if campaign.pollNumbers >= 50 {
            return Constants.Colors.positive
        } else if campaign.pollNumbers >= 35 {
            return Color.yellow
        } else {
            return Constants.Colors.negative
        }
    }

    private var formattedFunds: String {
        let amount = Int(truncating: character.campaignFunds as NSDecimalNumber)
        if amount >= 1_000_000 {
            return String(format: "%.1fM", Double(amount) / 1_000_000.0)
        } else if amount >= 1_000 {
            return String(format: "%.1fK", Double(amount) / 1_000.0)
        } else {
            return "\(amount)"
        }
    }
}

// MARK: - Campaign Activities Card

struct CampaignActivitiesCard: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Campaign Activities")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                ForEach(gameManager.electionManager.getAvailableCampaignActivities(), id: \.self) { activityType in
                    CampaignActivityButton(activityType: activityType, character: character)
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

// MARK: - Campaign Activity Button

struct CampaignActivityButton: View {
    @EnvironmentObject var gameManager: GameManager
    let activityType: CampaignActivity.ActivityType
    let character: Character

    var body: some View {
        Button(action: {
            performActivity()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.political.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: activityType.iconName)
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.political)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(activityType.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Text("+\(String(format: "%.1f", activityType.basePollImpact))% polls  •  $\(formattedCost)")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(canAfford ? Color.white.opacity(0.05) : Color.white.opacity(0.02))
            )
            .opacity(canAfford ? 1.0 : 0.5)
        }
        .disabled(!canAfford)
    }

    private var canAfford: Bool {
        character.campaignFunds >= activityType.baseCost
    }

    private var formattedCost: String {
        let cost = Int(truncating: activityType.baseCost as NSDecimalNumber)
        if cost >= 1000 {
            return "\(cost / 1000)K"
        } else {
            return "\(cost)"
        }
    }

    private func performActivity() {
        var updatedCharacter = character
        if let activity = gameManager.electionManager.performCampaignActivity(activityType, character: &updatedCharacter) {
            gameManager.characterManager.updateCharacter(updatedCharacter)
        }
    }
}

// MARK: - Activity Log Card

struct ActivityLogCard: View {
    let activities: [CampaignActivity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activities")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 8) {
                ForEach(activities.suffix(5).reversed()) { activity in
                    ActivityLogRow(activity: activity)
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

struct ActivityLogRow: View {
    let activity: CampaignActivity

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: activity.type.iconName)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.political)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.type.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)

                Text(activity.description)
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            Text("+\(String(format: "%.1f", activity.pollImpact))%")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Constants.Colors.positive)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - No Campaign View

struct NoCampaignView: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "megaphone.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryText)

            Text("No Active Campaign")
                .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                .foregroundColor(.white)

            Text("Start a campaign to run for your next political position")
                .font(.system(size: Constants.Typography.bodyTextSize))
                .foregroundColor(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let nextPosition = getNextPosition() {
                Button(action: {
                    startCampaign(for: nextPosition)
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Campaign for \(nextPosition.title)")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Constants.Colors.political)
                    )
                }
            }

            Spacer()
        }
    }

    private func getNextPosition() -> Position? {
        guard let currentPosition = character.currentPosition else {
            // Return first position if no current position
            return Position(
                title: "City Council Member",
                level: 2,
                termLengthYears: 4,
                minAge: 21,
                approvalRating: 30,
                reputation: 20,
                funds: 10000
            )
        }

        // Return next level position
        return Position(
            title: "Mayor",
            level: currentPosition.level + 1,
            termLengthYears: 4,
            minAge: 25,
            approvalRating: 40,
            reputation: 30,
            funds: 50000
        )
    }

    private func startCampaign(for position: Position) {
        var updatedCharacter = character
        let _ = gameManager.electionManager.startCampaign(for: position, character: updatedCharacter)
        gameManager.characterManager.updateCharacter(updatedCharacter)
    }
}

// MARK: - Placeholder Empty State

struct PlaceholderEmptyState: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(message)
                .font(.system(size: Constants.Typography.bodyTextSize))
                .foregroundColor(Constants.Colors.secondaryText)
        }
    }
}

#Preview {
    CampaignView()
        .environmentObject(GameManager.shared)
}
