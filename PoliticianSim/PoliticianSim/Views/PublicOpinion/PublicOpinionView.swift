//
//  PublicOpinionView.swift
//  PoliticianSim
//
//  Displays public opinion polling, media coverage, and social media
//

import SwiftUI

struct PublicOpinionView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: OpinionTab = .overview
    @State private var selectedAction: PublicOpinionAction?
    @State private var showingActionSheet = false

    enum OpinionTab {
        case overview, demographics, media
    }

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

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

                    Text("Public Opinion")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        var char = character
                        _ = gameManager.publicOpinionManager.conductPoll(character: char)
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                            .foregroundColor(Constants.Colors.accent)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Tab Selector
                OpinionTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Content
                ScrollView {
                    VStack(spacing: 15) {
                        switch selectedTab {
                        case .overview:
                            OverviewSection()
                        case .demographics:
                            DemographicsSection()
                        case .media:
                            MediaSection()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }

            // Side Menu
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .customAlert(
            isPresented: $showingActionSheet,
            title: selectedAction?.name ?? "Public Opinion Action",
            message: selectedAction != nil ? "\(selectedAction!.description)\n\nThis will cost \(formatCost(selectedAction!)) and last \(selectedAction!.duration) days." : "",
            primaryButton: "Perform Action",
            primaryAction: {
                if let action = selectedAction {
                    var char = character
                    let result = gameManager.publicOpinionManager.performAction(action, character: &char)
                    gameManager.characterManager.updateCharacter(char)
                    if result.success {
                        gameManager.publicOpinionManager.generateMediaCoverage(character: char)
                    }
                }
            },
            secondaryButton: "Cancel"
        )
    }

    private func formatCost(_ action: PublicOpinionAction) -> String {
        var costs: [String] = []
        if let cost = action.cost {
            let millions = NSDecimalNumber(decimal: cost).doubleValue / 1_000_000
            costs.append("$\(String(format: "%.1fM", millions))")
        }
        if action.reputationCost > 0 {
            costs.append("\(action.reputationCost) Reputation")
        }
        return costs.isEmpty ? "Free" : costs.joined(separator: ", ")
    }
}

// MARK: - Tab Selector

struct OpinionTabSelector: View {
    @Binding var selectedTab: PublicOpinionView.OpinionTab

    var body: some View {
        HStack(spacing: 8) {
            OpinionTabButton(title: "Overview", isSelected: selectedTab == .overview) {
                selectedTab = .overview
            }
            OpinionTabButton(title: "Demographics", isSelected: selectedTab == .demographics) {
                selectedTab = .demographics
            }
            OpinionTabButton(title: "Media", isSelected: selectedTab == .media) {
                selectedTab = .media
            }
        }
    }

    struct OpinionTabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Constants.Colors.accent.opacity(0.3) : Color.clear)
                    )
            }
        }
    }
}

// MARK: - Overview Section

struct OverviewSection: View {
    @EnvironmentObject var gameManager: GameManager

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var body: some View {
        VStack(spacing: 15) {
            // Current approval
            if let poll = gameManager.publicOpinionManager.currentPoll {
                ApprovalCard(poll: poll)
            }

            // Social media overview
            SocialMediaCard(metrics: gameManager.publicOpinionManager.socialMetrics)

            // Available actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Public Engagement Actions")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                let actions = PublicOpinionAction.getAvailableActions(character: character)
                ForEach(actions) { action in
                    PublicOpinionActionButton(action: action) {
                        performAction(action)
                    }
                }
            }
        }
    }

    private func performAction(_ action: PublicOpinionAction) {
        var char = character
        let result = gameManager.publicOpinionManager.performAction(action, character: &char)
        gameManager.characterManager.updateCharacter(char)
        if result.success {
            gameManager.publicOpinionManager.generateMediaCoverage(character: char)
        }
    }
}

struct ApprovalCard: View {
    let poll: OpinionPoll

    var trendColor: Color {
        Color(
            red: poll.trendDirection.color.red,
            green: poll.trendDirection.color.green,
            blue: poll.trendDirection.color.blue
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Current Approval")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: poll.trendDirection.iconName)
                        .foregroundColor(trendColor)
                    Text(poll.trendDirection.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(trendColor)
                }
            }

            // Large approval number
            Text(String(format: "%.1f%%", poll.overallApproval))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(approvalColor(poll.overallApproval))

            // Regional breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Regional Support")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                ForEach(Array(poll.regionalApproval.sorted(by: { $0.value > $1.value })), id: \.key) { region, approval in
                    HStack {
                        Text(region)
                            .font(.system(size: 13))
                            .foregroundColor(.white)

                        Spacer()

                        Text(String(format: "%.1f%%", approval))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(approvalColor(approval))
                    }
                }
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }

    private func approvalColor(_ approval: Double) -> Color {
        switch approval {
        case 70...: return .green
        case 50..<70: return Color(red: 0.5, green: 0.9, blue: 0.5)
        case 30..<50: return .orange
        default: return .red
        }
    }
}

struct SocialMediaCard: View {
    let metrics: SocialMediaMetrics

    var sentimentColor: Color {
        Color(
            red: metrics.sentiment.color.red,
            green: metrics.sentiment.color.green,
            blue: metrics.sentiment.color.blue
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Social Media Presence")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text(metrics.sentiment.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(sentimentColor)
            }

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(formatNumber(metrics.followers))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.accent)
                    Text("Followers")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Divider()
                    .frame(height: 30)
                    .background(Constants.Colors.secondaryText)

                VStack(spacing: 4) {
                    Text(String(format: "%.1f%%", metrics.engagementRate))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.accent)
                    Text("Engagement")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }

            // Trending topics
            if !metrics.trendingTopics.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Trending")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(metrics.trendingTopics, id: \.self) { topic in
                                Text(topic)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Constants.Colors.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Constants.Colors.accent.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        }
        return "\(number)"
    }
}

// MARK: - Demographics Section

struct DemographicsSection: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 15) {
            if let poll = gameManager.publicOpinionManager.currentPoll {
                // Group demographics by category
                let grouped = Dictionary(grouping: Array(poll.demographicBreakdown), by: { $0.key.category })

                ForEach(Array(grouped.keys.sorted()), id: \.self) { category in
                    DemographicCategoryCard(
                        category: category,
                        demographics: grouped[category] ?? []
                    )
                }

                // Issue approval
                IssueApprovalCard(issues: poll.issueApproval)
            } else {
                EmptyOpinionState(
                    icon: "chart.bar.fill",
                    message: "No Polling Data",
                    subtitle: "Conduct a poll to see detailed demographics"
                )
            }
        }
    }
}

struct DemographicCategoryCard: View {
    let category: String
    let demographics: [(key: DemographicGroup, value: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            ForEach(demographics.sorted(by: { $0.value > $1.value }), id: \.key) { group, approval in
                HStack {
                    Image(systemName: group.iconName)
                        .foregroundColor(Constants.Colors.accent)
                        .frame(width: 20)

                    Text(group.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.white)

                    Spacer()

                    Text(String(format: "%.1f%%", approval))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(approvalColor(approval))
                }
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }

    private func approvalColor(_ approval: Double) -> Color {
        switch approval {
        case 60...: return .green
        case 45..<60: return Color(red: 0.5, green: 0.9, blue: 0.5)
        case 30..<45: return .orange
        default: return .red
        }
    }
}

struct IssueApprovalCard: View {
    let issues: [IssueCategory: Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Issue Approval")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            ForEach(Array(issues.sorted(by: { $0.value > $1.value })), id: \.key) { issue, approval in
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: issue.iconName)
                            .foregroundColor(Color(
                                red: issue.color.red,
                                green: issue.color.green,
                                blue: issue.color.blue
                            ))
                            .frame(width: 20)

                        Text(issue.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.white)

                        Spacer()

                        Text(String(format: "%.1f%%", approval))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(approvalColor(approval))
                    }

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)

                            Rectangle()
                                .fill(Color(
                                    red: issue.color.red,
                                    green: issue.color.green,
                                    blue: issue.color.blue
                                ))
                                .frame(width: geometry.size.width * (approval / 100), height: 4)
                        }
                        .cornerRadius(2)
                    }
                    .frame(height: 4)
                }
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }

    private func approvalColor(_ approval: Double) -> Color {
        switch approval {
        case 60...: return .green
        case 45..<60: return Color(red: 0.5, green: 0.9, blue: 0.5)
        case 30..<45: return .orange
        default: return .red
        }
    }
}

// MARK: - Media Section

struct MediaSection: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 15) {
            // Media sentiment summary
            MediaSentimentCard()

            // Recent coverage
            let coverage = gameManager.publicOpinionManager.getRecentCoverage(limit: 15)
            if coverage.isEmpty {
                EmptyOpinionState(
                    icon: "newspaper.fill",
                    message: "No Media Coverage",
                    subtitle: "Take public actions to generate media attention"
                )
            } else {
                ForEach(coverage) { story in
                    MediaStoryCard(story: story)
                }
            }
        }
    }
}

struct MediaSentimentCard: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        let avgSentiment = gameManager.publicOpinionManager.getAverageMediaSentiment()

        VStack(spacing: 12) {
            Text("Media Sentiment")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text(sentimentLabel(avgSentiment))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(sentimentColor(avgSentiment))
                    Text("Overall Tone")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                VStack(spacing: 4) {
                    Text("\(gameManager.publicOpinionManager.mediaCoverage.count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.accent)
                    Text("Total Stories")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }

    private func sentimentLabel(_ value: Double) -> String {
        switch value {
        case 1.5...: return "Very Positive"
        case 0.5..<1.5: return "Positive"
        case -0.5...0.5: return "Neutral"
        case -1.5..<(-0.5): return "Negative"
        default: return "Very Negative"
        }
    }

    private func sentimentColor(_ value: Double) -> Color {
        switch value {
        case 1...: return .green
        case 0..<1: return Color(red: 0.5, green: 0.9, blue: 0.5)
        case -1...0: return .orange
        default: return .red
        }
    }
}

struct MediaStoryCard: View {
    let story: MediaCoverage

    var sentimentColor: Color {
        Color(
            red: story.sentiment.color.red,
            green: story.sentiment.color.green,
            blue: story.sentiment.color.blue
        )
    }

    var categoryColor: Color {
        Color(
            red: story.category.color.red,
            green: story.category.color.green,
            blue: story.category.color.blue
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: story.sentiment.iconName)
                    .foregroundColor(sentimentColor)

                Text(story.sentiment.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(sentimentColor)

                Spacer()

                Text(story.category.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(categoryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor.opacity(0.2))
                    .cornerRadius(6)
            }

            Text(story.headline)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)

            HStack {
                Text(formatDate(story.date))
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text("Impact: \(String(format: "%+.1f%%", story.impactOnApproval))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(story.impactOnApproval >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Action Button

struct PublicOpinionActionButton: View {
    let action: PublicOpinionAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: action.type.iconName)
                    .foregroundColor(Constants.Colors.accent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(action.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Text(formatCost())
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("+\(String(format: "%.1f%%", action.approvalImpact))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)

                    Text("\(action.duration)d")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatCost() -> String {
        var costs: [String] = []
        if let cost = action.cost {
            let millions = NSDecimalNumber(decimal: cost).doubleValue / 1_000_000
            costs.append("$\(String(format: "%.1fM", millions))")
        }
        if action.reputationCost > 0 {
            costs.append("\(action.reputationCost) Rep")
        }
        return costs.isEmpty ? "Free" : costs.joined(separator: ", ")
    }
}

// MARK: - Empty State

struct EmptyOpinionState: View {
    let icon: String
    let message: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.5))

            Text(message)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    PublicOpinionView()
        .environmentObject(GameManager.shared)
}
